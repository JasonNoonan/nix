return {
  {
    "bennypowers/nvim-regexplainer",
    opt = true,
    setup = function() table.insert(astronvim.file_plugins, "nvim-regexplainer") end,
    config = function()
      require("regexplainer").setup {
        mappings = {
          toggle = "<leader>lx",
        },
      }
    end,
    requires = {
      "nvim-treesitter/nvim-treesitter",
      "MunifTanjim/nui.nvim",
    },
  },
  {
    "mattn/emmet-vim",
    ft = { "svelte", "html", "heex", "elixir", "javascript" },
    config = function()
      vim.g.user_emmet_settings = {
        ["javascript.jsx"] = {
          extends = "jsx",
        },
        elixir = {
          extends = "html",
        },
        eelixir = {
          extends = "html",
        },
        heex = {
          extends = "html",
        },
      }
      vim.g.user_emmet_mode = "inv"
    end,
    event = "VeryLazy",
  },
  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function() require("lsp_signature").setup() end,
  },
  {
    "tpope/vim-dadbod",
    dependencies = {
      "kristijanhusak/vim-dadbod-ui",
      "kristijanhusak/vim-dadbod-completion",
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = true
      vim.g.db_ui_execute_on_save = false
      vim.g.db_ui_save_location = "./json_queries"
      vim.g.db_ui_disable_mappings = false
      vim.g.db_url = os.getenv "DBUI_URL"
      vim.g.db_ui_use_nvim_notify = true
    end,
    cmd = {
      "DBUI",
    },
    keys = {
      {
        "<leader><leader>r",
        ":normal vip<CR><PLUG>(DBUI_ExecuteQuery)",
        { description = "run the sql query (dadbod)" },
      },
      {
        "<leader><leader>d",
        "<cmd>DBUI<cr>",
        { description = "start the dadbod UI" },
      },
    },
  },
  {
    "tpope/vim-fugitive",
    dependencies = { "tpope/vim-rhubarb" },
    event = "VimEnter",
    keys = {
      { "<leader><leader>gl", ":Gclog<CR>", { description = "git log" } },
      { "<leader><leader>gh", ":0Gclog<CR>", { description = "git history for current file" } },
    },
  },
}
