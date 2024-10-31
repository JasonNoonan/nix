return {
	{
		"janko/vim-test",
		dependencies = {
			"tpope/vim-dispatch",
			"preservim/vimux",
		},
		event = "VimEnter",
		config = function()
			vim.g["test#strategy"] = {
				nearest = "vimux_watch",
				file = "vimux_watch",
				suite = "vimux_watch",
			}
			vim.g["preserve_screen"] = true
			vim.g["test#csharp#runner"] = "dotnettest"
			vim.g["test#custom_strategies"] = {
				vimux_watch = function(args)
					vim.g.VimuxOrientation = "v"
					vim.g.VimuxHeight = "30"
					vim.cmd("call VimuxClearTerminalScreen()")
					vim.cmd("call VimuxClearRunnerHistory()")
					vim.cmd(string.format("call VimuxRunCommand('fd . | entr -c %s')", args))
				end,
				vimux_watch_side_split = function(args)
					vim.g.VimuxOrientation = "h"
					vim.g.VimuxWidth = "30"
					vim.cmd("call VimuxClearTerminalScreen()")
					vim.cmd("call VimuxClearRunnerHistory()")
					vim.cmd(string.format("call VimuxRunCommand('fd . | entr -c %s')", args))
				end,
			}
		end,
		keys = {
			{ "<leader>rr", "<CMD>VimuxPromptCommand<CR>", { desc = "run the runsman" } },
			{ "<leader>r.", "<CMD>VimuxRunLastCommand<CR>", { desc = "run the last run command" } },
			{ 
				"<leader>rf",  
				function() 
					local pickers = require 'telescope.pickers'
					local sorters = require 'telescope.sorters'
					local finders = require 'telescope.finders'

  				local picker = pickers.new {
    				finder = finders.new_oneshot_job(
      				{ "tmux-file-paths" },
      				{
        				entry_maker = function(entry)
          				local _, _, filename, lnum = string.find(entry, "(.+):(%d+)")

          				return {
            				value = entry,
            				ordinal = entry,
            				display = entry,
            				filename = filename,
            				lnum = tonumber(lnum),
            				col = 0
          				}
        				end
      				}
    				),
    				sorter = sorters.get_generic_fuzzy_sorter(),
    				previewer = require 'telescope.previewers'.vim_buffer_vimgrep.new {}
  				}

  				picker:find()
				end, 
				{ desc = "find file paths in open buffers" } 
			},
			{ "<leader>rc", "<CMD>VimuxClearTerminalScreen<CR>", { desc = "clear the current run terminal" } },
			{ "<leader>rq", "<CMD>VimuxCloseRunner<CR>", { desc = "close the runner" } },
			{ "<leader>r?", "<CMD>VimuxInspectRunner<CR>", { desc = "inspect the runner" } },
			{ "<leader>r!", "<CMD>VimuxInterruptRunner<CR>", { desc = "interrupt the runner (bang'er)" } },
			{ "<leader>rz", "<CMD>VimuxZoomRunner<CR>", { desc = "zoom the runner" } },
			{ "<leader>tt", "<cmd>TestFile<cr>", { desc = "run test watcher" } },
			{
				"<leader>tT",
				"<cmd>TestNearest -strategy=vimux_watch_side_split<cr><cr>",
				{ desc = "run test for whole file" },
			},
			{ "<leader>tn", "<cmd>TestNearest<cr>", { desc = "run nearest test to cursor" } },
			{
				"<leader>tN",
				"<cmd>TestNearest -strategy=vimux_watch_side_split<cr><cr>",
				{ desc = "run nearest test to cursor" },
			},
			{ "<leader>ts", "<cmd>TestSuite<cr>", { desc = "run test suite" } },
			{ "<leader>tS", "<cmd>TestSuite -strategy=vimux_watch_side_split<cr><cr>", { desc = "run test suite" } },
			{ "<leader>t.", "<cmd>TestLast<cr>", { desc = "re-run the last test run" } },
			{
				"<leader>t>",
				"<cmd>TestLast -strategy=vimux_watch_side_split<cr><cr>",
				{ desc = "re-run the last test run" },
			},
			{ "<leader>tv", "<cmd>TestVisit<cr>", { desc = "visit the last run test" } },
		},
	},
	{
		"tpope/vim-projectionist",
		config = function()
			vim.g.projectionist_heuristics = {
				["*"] = {
					["lib/*.ex"] = {
						alternate = {
							"lib/{}_test.exs",
							"test/{}_test.exs",
						},
						type = "source",
					},
					["test/*_test.exs"] = {
						alternate = {
							"lib/{}.ex",
						},
					},
				},
			}
		end,
		keys = {
			{ "<leader>t<backspace>", "<cmd>A<cr>", { description = "jump to test from source file or viceversa" } },
		},
		event = "VeryLazy",
	},
}
