vim.pack.add({
    {
        src = "https://github.com/nvim-treesitter/nvim-treesitter",
        version = "main",
    },
    {
        src = "https://github.com/ibhagwan/fzf-lua",
    },
    {
        src = "https://github.com/windwp/nvim-autopairs",
    },
    {
        src = "https://github.com/rebelot/kanagawa.nvim",
    }
})

-- Colorscheme
vim.cmd.colorscheme("kanagawa")

-- Plugin configuration
require("fzf-lua").setup({})

require("nvim-autopairs").setup({
    map_cr = true,
    check_ts = false,
})

vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
        pcall(vim.treesitter.start, args.buf)
    end,
})
