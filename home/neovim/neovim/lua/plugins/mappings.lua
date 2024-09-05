vim.keymap.set({ "n", "v" }, "<C-c><C-c>", function()
	-- yank text into v register
end)
return {
	{
		"AstroNvim/astrocore",
		---@type AstroCoreOpts
		opts = {
			mappings = {
				-- first key is the mode
				n = {
					-- scratchpad runner
					["<C-c><C-c>"] = {
						function()
							if vim.api.nvim_get_mode()["mode"] == "n" then
								vim.cmd('normal vip"vy')
							else
								vim.cmd('normal "vy')
							end
							-- construct command with v register as command to send
							-- vim.cmd(string.format('call VimuxRunCommand("%s")', vim.trim(vim.fn.getreg('v'))))
							vim.cmd("call VimuxRunCommand(@v)")
						end,
					},
					-- second key is the lefthand side of the map
					-- hop.nvim
					["<leader>bt"] = { "<cmd>BufferLineSortByTabs<cr>", desc = "Sort by tabs" },
					["<leader>gd"] = { "<cmd>DiffviewOpen<cr>", desc = "View git diff in Diffview" },
					["<leader>gdc"] = { "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
					["<leader>ff"] = { "<cmd>Telescope git_files<cr>", desc = "Search all files in git" },
					["<leader>fs"] = { "<cmd>Telescope git_status<cr>", desc = "Search all changes in git" },
					["<leader>lg"] = { "<cmd>Neogen<cr>", desc = "Generate annotation for the current node" },
					-- tmux bullshit
					["<leader><leader>t1"] = {
						function()
							vim.fn.system("tmux select-window -t :=1")
						end,
						desc = "Jump to first tmux window in session",
					},
					["<leader><leader>t2"] = {
						function()
							vim.fn.system("tmux select-window -t :=2")
						end,
						desc = "Jump to second tmux window in session",
					},
					["<leader><leader>t3"] = {
						function()
							vim.fn.system("tmux select-window -t :=3")
						end,
						desc = "Jump to third tmux window in session",
					},
					["<leader><leader>t4"] = {
						function()
							vim.fn.system("tmux select-window -t :=4")
						end,
						desc = "Jump to fourth tmux window in session",
					},
					["<leader><leader>tn"] = {
						function()
							vim.fn.system("tmux next-window")
						end,
						desc = "Move to next window in current tmux session",
					},
					["<leader><leader>tp"] = {
						function()
							vim.fn.system("tmux previous-window")
						end,
						desc = "Move to previous window in current tmux session",
					},
					["<leader><leader>tq"] = {
						function()
							vim.fn.system("tmux kill-server")
						end,
						desc = "Kills the tmux server",
					},
					["<leader><leader>t"] = { name = "Tmux" },
					-- resize with arrows
					["<Up>"] = {
						function()
							require("smart-splits").resize_up(2)
						end,
						desc = "Resize split up",
					},
					["<Down>"] = {
						function()
							require("smart-splits").resize_down(2)
						end,
						desc = "Resize split down",
					},
					["<Left>"] = {
						function()
							require("smart-splits").resize_left(2)
						end,
						desc = "Resize split left",
					},
					["<Right>"] = {
						function()
							require("smart-splits").resize_right(2)
						end,
						desc = "Resize split right",
					},
					["<leader>b"] = { name = "Buffer" },
					L = {
						function()
							require("astrocore.buffer").nav(vim.v.count > 0 and vim.v.count or 1)
						end,
						desc = "Next buffer",
					},
					H = {
						function()
							require("astrocore.buffer").nav(-(vim.v.count > 0 and vim.v.count or 1))
						end,
						desc = "Previous buffer",
					},
				},
				t = {
					["<c-q>"] = { "<c-\\><c-n>", desc = "Terminal normal mode" },
					["<esc><esc>"] = { "<c-\\><c-n>:q<cr>", desc = "Terminal quit" },
				},
				v = {
					-- scratchpad runner
					["<C-c><C-c>"] = {
						function()
							if vim.api.nvim_get_mode()["mode"] == "n" then
								vim.cmd('normal vip"vy')
							else
								vim.cmd('normal "vy')
							end
							-- construct command with v register as command to send
							-- vim.cmd(string.format('call VimuxRunCommand("%s")', vim.trim(vim.fn.getreg('v'))))
							vim.cmd("call VimuxRunCommand(@v)")
						end,
					},
					["<"] = {"<gv", desc = "maintain visual selection while unindenting"},
					[">"] = {">gv", desc = "maintain visual selection while indenting"},
					["p"] = {'"_dp', desc = "move overwritten text to the blackhole register"}, 
					-- Noice errors (we think) when using the below 
					-- ["J"] = {":m '>+1<cr>gv=gv'", desc = "complicated movement of whole block down relative to other lines"},
					-- ["K"] = {":m '<-2<cr>gv=gv'", desc = "complicated movement of whole block up relative to other lines"},
				},
			},
		},
	},
	{
		"AstroNvim/astrolsp",
		---@type AstroLSPOpts
		opts = {
			mappings = {
				n = {
					-- this mapping will only be set in buffers with an LSP attached
					K = {
						function()
							vim.lsp.buf.hover()
						end,
						desc = "Hover symbol details",
					},
					-- condition for only server with declaration capabilities
					gD = {
						function()
							vim.lsp.buf.declaration()
						end,
						desc = "Declaration of current symbol",
						cond = "textDocument/declaration",
					},
				},
			},
		},
	},
}
