return {
	{ "williamboman/mason.nvim", opts = { PATH = "append" } },
	{
		"williamboman/mason-lspconfig.nvim",
		opts = function(_, opts)
			-- add more things to the ensure_installed table protecting against community packs modifying it
			opts.automatic_installation = true
			opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
				"netcoredbg",
				"tsserver",
				"rust_analyzer",
				"lua_ls",
				"yamlls",
				"html",
			})
		end,
	},
	{
		"jay-babu/mason-null-ls.nvim",
		opts = function(_, opts)
			-- add more things to the ensure_installed table protecting against community packs modifying it
			opts.ensure_installed = require("astrocore").list_insert_unique(
				opts.ensure_installed,
				{ "prettierd", "eslint_d", "stylua", "eslint-lsp", "rustfmt" }
			)

			opts.handlers = require("astrocore").list_insert_unique(opts.handlers, {
				prettierd = function()
					local null_ls = require("null-ls")
					null_ls.register(null_ls.builtins.formatting.prettierd.with({
						extra_filetypes = { "markdown", "rmd", "qmd" },
					}))
				end,
			})
		end,
	},
}
