local M = {}

--- Return the buffers represented by the bufferline.
function M.buffers()
    local buffers = {}

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf)
            and vim.bo[buf].buflisted
        then
            table.insert(buffers, buf)
        end
    end

    return buffers
end

--- Display name for a buffer
local function terminal_command(pid)
    local children_path = "/proc/" .. pid .. "/task/" .. pid .. "/children"
    local file = io.open(children_path, "r")

    if not file then
        return nil
    end

    local children = file:read("*a")
    file:close()

    local child_pid = children:match("%d+")

    if not child_pid then
        return nil
    end

    local comm = io.open("/proc/" .. child_pid .. "/comm", "r")

    if not comm then
        return nil
    end

    local command = comm:read("*l")
    comm:close()

    return command
end

local function name(buf)
    if vim.bo[buf].buftype == "terminal" then
        -- get the directory & command from /proc
        local shell = vim.fn.fnamemodify(vim.o.shell, ":t")

        local job = vim.bo[buf].channel
        local pid = vim.fn.jobpid(job)

        if pid <= 0 then
            return shell
        end

        local cwd = vim.fn.resolve("/proc/" .. pid .. "/cwd")
        local dirname = vim.fn.fnamemodify(cwd, ":t")

        local command = terminal_command(pid) or shell

        return command .. ":" .. dirname
    else -- not a terminal buffer
        local path = vim.api.nvim_buf_get_name(buf)

        if path == "" then
            return "[No Name]"
        end

        return vim.fn.fnamemodify(path, ":t")
    end
end

--- Render the bufferline.
function M.render()
    local current = vim.api.nvim_get_current_buf()
    local parts = {}

    for _, buf in ipairs(M.buffers()) do
        local text = " " .. name(buf)

        if vim.bo[buf].modified then
            text = text .. " +"
        end

        text = text .. " "

        if buf == current then
            table.insert(parts, "%#TabLineSel#" .. text)
        else
            table.insert(parts, "%#TabLine#" .. text)
        end
    end

    table.insert(parts, "%#TabLineFill#")

    return table.concat(parts)
end

--- Switch to the next listed buffer.
function M.next()
    local buffers = M.buffers()

    if #buffers < 2 then
        return
    end

    local current = vim.api.nvim_get_current_buf()

    for i, buf in ipairs(buffers) do
        if buf == current then
            local next_buf = buffers[(i % #buffers) + 1]
            vim.api.nvim_set_current_buf(next_buf)
            return
        end
    end
end

--- Switch to the previous listed buffer.
function M.previous()
    local buffers = M.buffers()

    if #buffers < 2 then
        return
    end

    local current = vim.api.nvim_get_current_buf()

    for i, buf in ipairs(buffers) do
        if buf == current then
            local previous = i - 1

            if previous == 0 then
                previous = #buffers
            end

            vim.api.nvim_set_current_buf(buffers[previous])
            return
        end
    end
end

--- Delete a buffer after switching away from it.
local function delete_buffer(buf, force)
    local buffers = M.buffers()
    local replacement = nil

    for i, candidate in ipairs(buffers) do
        if candidate == buf then
            replacement = buffers[i + 1] or buffers[i - 1]
            break
        end
    end

    if replacement then
        vim.api.nvim_set_current_buf(replacement)
    else
        vim.cmd("enew")
    end

    vim.api.nvim_buf_delete(buf, {
        force = force,
    })
end

--- Close the current buffer.
function M.close_current()
    local buf = vim.api.nvim_get_current_buf()


    -- Unlisted buffers
    if not vim.bo[buf].buflisted then
        local alternate = vim.fn.bufnr("#")

        if alternate > 0 and vim.api.nvim_buf_is_valid(alternate) then
            vim.api.nvim_set_current_buf(alternate)
        else
            vim.cmd("enew")
        end
        return

    -- Terminal buffers
    elseif vim.bo[buf].buftype == "terminal" then
        delete_buffer(buf, true)
        return

    -- Normal buffers
    else

        if not vim.bo[buf].modified then
            delete_buffer(buf, false)
            return
        end

        local filename = name(buf)

        local choice = vim.fn.confirm(
            'Save changes to "' .. filename .. '"?',
            "&Yes\n&No\n&Cancel",
            3
        )

        -- Cancel / Esc
        if choice == 0 or choice == 3 then
            return
        end

        -- Yes
        if choice == 1 then
            if vim.api.nvim_buf_get_name(buf) == "" then
                -- Let native :write handle choosing a filename.
                vim.cmd("write")
            else
                vim.api.nvim_buf_call(buf, function()
                    vim.cmd("write")
                end)
            end

            -- A failed/cancelled write should not destroy the buffer.
            if vim.bo[buf].modified then
                return
            end

            delete_buffer(buf, false)
            return
        end

        -- No
        if choice == 2 then
            delete_buffer(buf, true)
        end
    end
end

vim.o.tabline = "%!v:lua.require'bufferline'.render()"

return M
