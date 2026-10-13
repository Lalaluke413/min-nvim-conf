local map = vim.keymap.set

-- Insert mode
map("i", "jk", "<Esc>", {
    desc = "Exit insert mode",
})

-- Paste without replacing the current register
map("v", "<leader>p", '"_dP', {
    desc = "Paste without replacing register",
})

-- Buffers
map("n", "<Tab>", function()
    require("bufferline").next()
end, {
    desc = "Next buffer",
})


map("n", "<S-Tab>", function()
    require("bufferline").previous()
end, {
    desc = "Previous buffer",
})

map("n", "<leader>x", function()
    require("bufferline").close_current()
end, {
    desc = "Close buffer",
})

-- Fuzzy finding
map("n", "<leader>ff", function()
    require("fzf-lua").files()
end, {
    desc = "Find files",
})

map("n", "<leader>fw", function()
    require("fzf-lua").live_grep()
end, {
    desc = "Find files",
})

map("n", "<leader>fb", function()
    require("fzf-lua").buffers()
end, {
    desc = "Find files",
})

map("n", "<leader>fo", function()
    require("fzf-lua").oldfiles()
end, {
    desc = "Find files",
})

-- Native file explorer
map("n", "<leader>e", "<cmd>Explore<CR>", {
    desc = "File explorer",
})

-- Terminal
map("n", "<leader>h", "<cmd>split | terminal<CR>", {
    desc = "Horizontal terminal",
})

map("n", "<leader>v", "<cmd>vsplit | terminal<CR>", {
    desc = "Vertical terminal",
})

-- Window navigation
map("n", "<C-h>", "<C-w>h", {
    desc = "Move to left window",
})

map("n", "<C-j>", "<C-w>j", {
    desc = "Move to lower window",
})

map("n", "<C-k>", "<C-w>k", {
    desc = "Move to upper window",
})

map("n", "<C-l>", "<C-w>l", {
    desc = "Move to right window",
})
