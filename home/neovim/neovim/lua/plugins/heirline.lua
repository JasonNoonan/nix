return {
  "rebelot/heirline.nvim",
  opts = function(_, opts)
    local status = require "astroui.status"

    ---@diagnostic disable-next-line: inject-field
    status.component.grapple = {
      provider = function()
        local available, grapple = pcall(require, "grapple")
        if available then return grapple.statusline() end
      end,
    }
    opts.statusline = { -- statusline
      hl = { fg = "fg", bg = "bg" },
      status.component.mode { mode_text = { padding = { left = 1, right = 1 } } }, -- add the mode text
      status.component.git_branch(),
      status.component.grapple,
      status.component.file_info { filetype = {}, filename = false, file_modified = false },
      status.component.git_diff(),
      status.component.diagnostics(),
      status.component.fill(),
      status.component.fill(),
      status.component.lsp(),
      status.component.treesitter(),
      status.component.nav(),
      status.component.mode { surround = { separator = "right" } },
      -- remove the 2nd mode indicator on the right
    }

    -- return the final configuration table
    return opts
  end,
}
