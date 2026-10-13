local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Indentation
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.smartindent = true
opt.autoindent = true

-- UI
opt.cursorline = true
opt.cursorlineopt = "both"
opt.termguicolors = true

-- Show bufferline.
opt.showtabline = 2

-- Don't show mode twice; neovim already shows it in the command line.
opt.showmode = false

-- Window split
opt.splitbelow = true
opt.splitright = true

-- Comments
vim.api.nvim_create_autocmd("FileType", {
    callback = function()
        vim.opt_local.formatoptions:remove("o")
        vim.opt_local.formatoptions:append("r")
    end
})
