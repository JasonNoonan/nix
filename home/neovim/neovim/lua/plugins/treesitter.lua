return {
	"nvim-treesitter/nvim-treesitter",
	opts = function(_, opts)
		opts.ensure_installed = "all"
		opts.highlight = {
			enable = true,
		}
	end,
}
