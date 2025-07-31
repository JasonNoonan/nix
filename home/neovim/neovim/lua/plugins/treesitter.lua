-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      -- "all"
      -- add more arguments for adding more treesitter parsers
    },
    highlight = {
      enable = true,
    },
  },
}
