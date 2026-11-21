-- ~/.config/nvim/lua/config/lsp.lua

-- Store known filetypes for lazy loading
vim.g.known_fts = {
    "go", "rust", "lua", "vimdoc", "zig", "c", "cpp",
    "javascript", "typescript", "tsx", "astro", "python",
  }
  
  local M = {}
  
  -- Capabilities (compatible with nvim-cmp if present)
  M.MakeClientCapabilities = function(capabilities)
    local has_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
    local base = vim.lsp.protocol.make_client_capabilities()
    if has_cmp then
      base = cmp_lsp.default_capabilities(base)
    end
    if capabilities == nil or (type(capabilities) == "table" and vim.tbl_isempty(capabilities)) then
      return base
    end
    return vim.tbl_deep_extend("force", base, capabilities)
  end
  
  -- Simple root finder using vim.fs
  local function root_pattern(patterns)
    return function(fname)
      local dir = vim.fs.dirname(fname)
      local found = vim.fs.find(patterns, { upward = true, path = dir })
      if #found > 0 then
        return vim.fs.dirname(found[1])
      end
      return vim.loop.cwd()
    end
  end
  
  -- Generic starter using vim.lsp.start
  local function start_server(bufnr, cmd, settings, init_options, filetypes, root_dir_fn, capabilities)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local root_dir = root_dir_fn and root_dir_fn(fname) or vim.loop.cwd()
  
    local ok = vim.lsp.start({
      name = cmd[1],
      cmd = cmd,
      root_dir = root_dir,
      capabilities = capabilities,
      settings = settings,
      init_options = init_options,
    })
  
    if not ok then
      vim.notify(("Failed to start LSP: %s"):format(cmd[1]), vim.log.levels.ERROR)
    end
  end
  
  -- Per-language starters
  local starters = {}
  
  starters.gopls = function(bufnr, capabilities)
    start_server(bufnr, { "gopls" }, nil, nil, { "go" },
      root_pattern({ "go.work", "go.mod", ".git" }), capabilities)
  end
  
  starters.rust_analyzer = function(bufnr, capabilities)
    start_server(bufnr, { "rust-analyzer" }, nil, nil, { "rust" },
      root_pattern({ "Cargo.toml", ".git" }), capabilities)
  end
  
  starters.lua_ls = function(bufnr, capabilities)
    start_server(bufnr, { "lua-language-server" }, {
      Lua = {
        diagnostics = { globals = { "vim" } },
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    }, nil, { "lua" }, root_pattern({ ".luarc.json", ".git" }), capabilities)
  end
  
  starters.zls = function(bufnr, capabilities)
    start_server(bufnr, { "zls" }, nil, nil, { "zig" },
      root_pattern({ "build.zig", ".git" }), capabilities)
  end
  
  starters.clangd = function(bufnr, capabilities)
    start_server(bufnr, { "clangd" }, nil, nil, { "c", "cpp" },
      root_pattern({ "compile_commands.json", ".git" }), capabilities)
  end
  
  -- TypeScript/JavaScript via typescript-language-server (tsserver equivalent)
  starters.ts_ls = function(bufnr, capabilities)
    start_server(bufnr, { "typescript-language-server", "--stdio" }, nil, {
      hostInfo = "neovim",
    }, { "typescript", "tsx", "javascript" },
      root_pattern({ "tsconfig.json", "jsconfig.json", "package.json", ".git" }), capabilities)
  end
  
  starters.astro = function(bufnr, capabilities)
    start_server(bufnr, { "astro-ls", "--stdio" }, nil, nil, { "astro" },
      root_pattern({ "astro.config.*", "package.json", ".git" }), capabilities)
  end
  
  starters.pyright = function(bufnr, capabilities)
    start_server(bufnr, { "pyright-langserver", "--stdio" }, {
      python = { analysis = { typeCheckingMode = "basic" } },
    }, nil, { "python" },
      root_pattern({ "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" }), capabilities)
  end
  
  -- Public API: list of servers we manage
  M.GetDefaultServers = function()
    return { "gopls", "rust_analyzer", "lua_ls", "zls", "clangd", "ts_ls", "astro", "pyright" }
  end
  
  -- Setup: attach autocommands to start servers on matching filetypes
  M.SetupServers = function(servers, opts)
    opts = opts or {}
    local capabilities = opts.capabilities or M.MakeClientCapabilities()
  
    -- Create a single augroup for LSP startups
    local group = vim.api.nvim_create_augroup("UserLspAutoStart", { clear = true })
  
    local ft_to_server = {
      go = "gopls",
      rust = "rust_analyzer",
      lua = "lua_ls",
      zig = "zls",
      c = "clangd",
      cpp = "clangd",
      typescript = "ts_ls",
      tsx = "ts_ls",
      javascript = "ts_ls",
      astro = "astro",
      python = "pyright",
    }
  
    for ft, server_name in pairs(ft_to_server) do
      if vim.tbl_contains(servers, server_name) then
        vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
          group = group,
          pattern = "*",
          callback = function(args)
            local bufnr = args.buf
            if vim.bo[bufnr].filetype == ft then
              -- Avoid starting duplicate clients for the buffer
              local existing = vim.lsp.get_clients({ bufnr = bufnr })
              for _, c in ipairs(existing) do
                if c.name == server_name then
                  return
                end
              end
              local starter = starters[server_name]
              if starter then
                starter(bufnr, capabilities)
              else
                vim.notify(("No starter for server '%s'"):format(server_name), vim.log.levels.WARN)
              end
            end
          end,
        })
      end
    end
  end
  
  return M
  