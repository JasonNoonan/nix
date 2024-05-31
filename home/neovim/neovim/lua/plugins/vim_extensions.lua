return {
	{ -- Neovim motions on speed!
		"phaazon/hop.nvim",
		branch = "v2", -- optional but strongly recommended,
		config = function()
			require("hop").setup()
		end,
		keys = {
			{ "<leader><leader>w", "<cmd>HopWord<cr>", desc = "Hop to a word" },
			{ "<leader><leader>p", "<cmd>HopPattern<cr>", desc = "Hop to a pattern" },
		},
		module = "hop",
		opts = true,
		setup = function()
			table.insert(astronvim.file_plugins, "hop.nvim")
		end,
	},
	{
		"L3MON4D3/LuaSnip",
		config = function(plugin, opts)
			require("astronvim.plugins.configs.luasnip")(plugin, opts) -- include the default astronvim config that calls the setup call
			-- add more custom luasnip configuration such as filetype extend or custom snippets
			local luasnip = require("luasnip")
			luasnip.filetype_extend("javascript", { "javascriptreact" })
			luasnip.filetype_extend("typescript", { "typescriptreact" })
		end,
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		opts = function()
			return {
				window = { position = "right" },
				filesystem = {
					follow_current_file = true,
					hijack_netrw_behavior = "open_default",
					cwd_target = {
						sidebar = "window",
					},
					filtered_items = {
						-- use H in neo-tree to un-hide hidden items if you need em
						hide_dotfiles = true,
						hide_gitignored = false,
						hide_by_name = { "node_modules", "_build", ".git", "deps" },
					},
				},
			}
		end,
	},
	{ "rcarriga/nvim-notify", opts = {
		background_colour = "#000",
		top_down = false,
		timeout = 2000,
	} },
	{
		"nvim-treesitter/playground",
		config = function()
			require("nvim-treesitter.configs").setup({
				playground = {
					enable = true,
					disable = {},
					updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
					persist_queries = false, -- Whether the query persists across vim sessions
					keybindings = {
						toggle_query_editor = "o",
						toggle_hl_groups = "i",
						toggle_injected_languages = "t",
						toggle_anonymous_nodes = "a",
						toggle_language_display = "I",
						focus_language = "f",
						unfocus_language = "F",
						update = "R",
						goto_node = "<cr>",
						show_help = "?",
					},
				},
			})
		end,
	},
	{
		"kylechui/nvim-surround",
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({})
		end,
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		config = {
			lsp = {
				signature = {
					enabled = false,
				},
				hover = {
					enabled = false,
				},
				message = {
					enabled = true,
					view = "notify",
				},
			},
		},
		opts = {
			-- add any options here
		},
		dependencies = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
			-- OPTIONAL:
			--   `nvim-notify` is only needed, if you want to use the notification view.
			--   If not available, we use `mini` as the fallback
			"rcarriga/nvim-notify",
		},
	},
	{
		"christoomey/vim-tmux-navigator",
		init = function()
			vim.g.tmux_navigator_disable_when_zoomed = true
		end,
	},
	{
		"tris203/precognition.nvim",
		config = {
			startVisible = false,
			hints = {
				["^"] = { text = "^", prio = 1 },
				["$"] = { text = "$", prio = 1 },
				["w"] = { text = "w", prio = 10 },
				["b"] = { text = "b", prio = 10 },
				["e"] = { text = "e", prio = 10 },
			},
			gutterHints = {
				--prio is not currentlt used for gutter hints
				["G"] = { text = "G", prio = 1 },
				["gg"] = { text = "gg", prio = 1 },
				["{"] = { text = "{", prio = 1 },
				["}"] = { text = "}", prio = 1 },
			},
		},
	},
	{ "chaoren/vim-wordmotion" }, -- More useful word motions for Vim
	{ "andymass/vim-matchup" }, -- vim match-up: even better % 👊 navigate and highlight matching words 👊 modern matchit and matchparen
}
