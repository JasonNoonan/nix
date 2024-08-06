return {
  "mfussenegger/nvim-dap",
  config = function()
		local dap = require("dap")
		dap.set_log_level("DEBUG")

		dap.adapters.coreclr = {
			type = "executable",
			command = "netcoredbg",
			args = { "--interpreter=vscode", "--engineLogging=dap_log.txt" },
		}

		dap.configurations.cs = {
			{
				type = "coreclr",
				name = "launch - Janus.Web",
				request = "launch",
				program = function()
					return vim.fn.input({
						prompt = "Path to dll: ",
						default = vim.fn.getcwd(),
						completion = "file",
					})
				end,
			},
		}
  end,
}
