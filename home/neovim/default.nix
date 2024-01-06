{ pkgs, inputs, ... }:
{
  programs.lazygit.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    plugins = [];
  };

  xdg.configFile = {
    nvim = {
      source = inputs.astronvim;
      force = true;
      recursive = true;
    };
    
    "astronvim/lua/user" = {
      source = ./neovim;
      force = true;
      recursive = true;
    };
  };
}
