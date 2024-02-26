{ pkgs, inputs, ... }:
{
  home.packages = [
    pkgs.cargo
    pkgs.nixpkgs-fmt
    pkgs.nodePackages.nodejs
    pkgs.postgresql_14
  ];

  programs.lazygit.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    plugins = with pkgs.vimPlugins; [
      telescope-fzf-native-nvim
    ];
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
