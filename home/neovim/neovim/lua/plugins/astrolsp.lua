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
			html = {
				filetypes = { "html", "heex" },
			},
			nil_ls = {
				settings = {
					["nil"] = {
						formatting = {
							command = { "nixpkgs-fmt" },
						},
					},
				},
			},
			yamlls = {
				settings = {
					yaml = {
						schemas = {
							["https://json.schemastore.org/github-workflow"] = ".github/workflows/*.{yml,yaml}",
							["https://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
							["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "docker-compose.*.{yml,yaml}",
							["https://json.schemastore.org/traefik-v2"] = "traefik.{yml,yaml}",
						},
					},
				},
			},
		})

		opts.formatting = {
			enabled = true,
			disabled = { "sumneko_lua", "rust_analyzer" },
			filter = function(client)
				-- only enable null-ls for some filetypes
				local null_ls_only = {
					"javascript", -- use prettierd
					"typescript", -- use prettierd
					"javascriptreact", -- use prettierd
					"typescriptreact", -- use prettierd
					"elixir", -- use mix
					"rust", -- use rustfmt
					"lua", -- use stylua
				}
				if vim.tbl_contains(null_ls_only, vim.bo.filetype) then
					return client.name == "null-ls"
				end

				-- enable all other clients
				return true
			end,
		}
	end,
}
