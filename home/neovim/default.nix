{ pkgs, inputs, ... }:
{
  home.packages = [ pkgs.nodePackages.nodejs pkgs.cargo pkgs.nixpkgs-fmt ];
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
