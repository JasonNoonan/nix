-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  -- we need to use the function notation to get access to the `lspconfig` module
  ---@param opts AstroLSPOpts
  opts = function(plugin, opts)
    -- insert "prolog_lsp" into our list of servers
    opts.servers = opts.servers or {}
    table.insert(opts.servers, "lexical")

    -- extend our configuration table to have our new prolog server
    opts.config = require("astrocore").extend_tbl(opts.config or {}, {
      -- this must be a function to get access to the `lspconfig` module
      lexical = {
        cmd = {
          "lexical",
        },
        filetypes = {
          "elixir",
          "eelixir",
        },
        name = "local_lexical",
        root_dir = require("lspconfig.util").root_pattern("mix.exs", ".git") or vim.loop.os_homedir(),
      },
    })
  end,
}
