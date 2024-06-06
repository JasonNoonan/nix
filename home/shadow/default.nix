{ config, pkgs, ... }:
{
  imports = [
    ../git.nix
    ../lang/dotnet.nix
    ../lang/elixir.nix
    ../lang/yaml.nix
    ../neovim
    ../shell.nix
    ../tmux
  ];

  home = {
    username = "jasonnoonan";
    homeDirectory = "/home/jasonnoonan";
    stateVersion = "23.11";
  };

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

  # k9s
  programs.k9s.enable = true;

  programs.vscode.enable = true;

  programs.zsh.shellAliases.handshake = "${pkgs.nh}/bin/nh os switch /etc/nixos";
}
