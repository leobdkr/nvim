-- ~/.config/nvim/lua/plugins/treesitter.lua

return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false, -- the main branch does not support lazy-loading
    config = function()
      require("nvim-treesitter").install({
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
      })

      -- Highlighting and indent are no longer enabled via setup();
      -- start them for every filetype that has an installed parser.
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(args.match)
          if not lang or not vim.treesitter.language.add(lang) then
            return
          end
          vim.treesitter.start(args.buf, lang)
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })

      -- Incremental selection is built into Neovim 0.12:
      -- in visual mode use `an` / `in` to grow / shrink the selection.
    end,
  }
