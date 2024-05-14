-- set vim options here (vim.<first_key>.<second_key> =  value)
-- If you need more control, you can use the function()...end notation
-- options = function(local_vim)
--   local_vim.opt.relativenumber = true
--   local_vim.g.mapleader = " "
--   local_vim.opt.whichwrap = vim.opt.whichwrap - { 'b', 's' } -- removing option from list
--   local_vim.opt.shortmess = vim.opt.shortmess + { I = true } -- add to option list
--
--   return local_vim
-- end,
-- vim.lsp.set_log_level("DEBUG")
return {
	opt = {
		-- set to true or false etc.
		expandtab = true,
		number = true, -- sets vim.opt.number
		relativenumber = false, -- sets vim.opt.relativenumber
		signcolumn = "yes", -- sets vim.opt.signcolumn to auto
		spell = true, -- sets vim.opt.spell
		swapfile = false, -- sets vim.opt.swapfile off
		wrap = false, -- sets vim.opt.wrap
		formatexpr = "",
	},
	g = {
		mapleader = " ", -- sets vim.g.mapleader
		cmp_enabled = true, -- enable completion at start
		autopairs_enabled = true, -- enable autopairs at start
		diagnostics_enabled = true, -- enable diagnostics at start
		status_diagnostics_enabled = true, -- enable diagnostics in statusline
	},
	o = {
		grepprg = "rg --vimgrep --hidden -g !.git",
	},
}
