-- ~/.config/nvim/lua/plugins/treesitter.lua

return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua",
          "vim",
          "vimdoc",
          "go",
          "rust",
          "zig",
          "c",
          "cpp",
          "python",
          "javascript",
          "typescript",
          "tsx",      -- React (TSX)
          "astro",    -- Astro files
          "json",
          "html",
          "css",
          "bash",
          "markdown",
          "markdown_inline",
          "yaml",
          "toml",
        },
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = { enable = true },
      })
    end,
  }
  