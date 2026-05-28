return {
	{
		"cfbender/claret.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("claret").setup({
				variant = "dark",
				transparent = false,
			})
			vim.cmd.colorscheme "claret"
		end,
	},
}
