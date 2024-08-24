return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter.configs")

      ts.setup({
        ensure_installed = { "c", "cpp", "lua", "vim", "vimdoc", "javascript", "css" },
        sync_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end
  },
}
