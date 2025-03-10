local lspkind = require("lspkind")

return {
	"hrsh7th/nvim-cmp",
	opts = {
		performance = {
			debounce = 300,
			throttle = 120,
			fetching_timeout = 100,
		},
		experimental = {
			ghost_text = true,
		},
		sources = {
			{ name = "luasnip", priority = 1000 },
			{ name = "nvim_lsp", priority = 999 },
			{ name = "path", priority = 650 },
			{ name = "buffer", priority = 400 },
		},
	},
}
