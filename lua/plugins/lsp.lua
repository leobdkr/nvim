-- ~/.config/nvim/lua/plugins/lsp.lua

return {
    -- Keep nvim-lspconfig installed if other plugins depend on it, but we won’t require it.
    "neovim/nvim-lspconfig",
    ft = vim.g.known_fts,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local configs = require("config.lsp")
      local capabilities = configs.MakeClientCapabilities()
  
      -- Start servers via built-in vim.lsp.start
      configs.SetupServers(configs.GetDefaultServers(), {
        capabilities = capabilities,
      })
  
      -- Hover UI: vim.lsp.buf.hover() ignores vim.lsp.handlers since 0.11,
      -- so pass the options directly (width is measured per call)
      local function hover()
        local width = vim.api.nvim_win_get_width(0)
        vim.lsp.buf.hover({
          border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
          max_width = math.floor(width * 0.75 + 0.5),
        })
      end

      -- Keymaps
      vim.keymap.set("n", "<leader>K", hover)
      vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition)
      vim.keymap.set("n", "<leader>f", function()
        vim.lsp.buf.format({ async = false })
      end)
  
      -- Telescope LSP actions
      vim.keymap.set("n", "<leader>gs", function()
        require("telescope.builtin").lsp_document_symbols()
      end)
      vim.keymap.set("n", "<leader>gr", function()
        require("telescope.builtin").lsp_references()
      end)
      vim.keymap.set("n", "<leader>ca", function()
        pcall(require, "telescope")
        vim.lsp.buf.code_action()
      end)
    end,
  }
  