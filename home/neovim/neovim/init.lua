-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.

-- Nix manages config files as symlinks to the store. When the store path
-- changes on rebuild, vim.loader's bytecode cache can serve stale modules
-- because the symlink path/mtime doesn't change. Reset to force a re-read.
if vim.loader and vim.loader.reset then vim.loader.reset() end

-- Nix-darwin may set $CC to a clang-wrapper in the nix store that becomes
-- invalid after garbage collection. Override with the system cc so that
-- tree-sitter can compile parsers at runtime.
if vim.env.CC and vim.env.CC:match "^/nix/store" then vim.env.CC = "cc" end

local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end

require "lazy_setup"
require "polish"
