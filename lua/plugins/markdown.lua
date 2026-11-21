-- ~/.config/nvim/lua/plugins/markdown.lua

return {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("render-markdown").setup({})

      vim.keymap.set("n", "<leader>mr", "<CMD>RenderMarkdown toggle<CR>", { desc = "Toggle markdown rendering" })
    end,
  }
