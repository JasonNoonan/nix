{ config, pkgs, ... }:
let
  gdk = pkgs.google-cloud-sdk.withExtraComponents (with pkgs.google-cloud-sdk.components; [
    gke-gcloud-auth-plugin
  ]);
in
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
    packages = [
      gdk
      pkgs.asdf
      pkgs.browsh
      pkgs.docker
      pkgs.docker-compose
      pkgs.firefox
      pkgs.go-task
      pkgs.kubernetes
      pkgs.microsoft-edge
      pkgs.python3
      pkgs.xdg-utils
    ];
  };

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

  # k9s
  programs.k9s.enable = true;

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
  };

  programs.vscode.enable = true;

  programs.zsh.shellAliases.handshake = "${pkgs.nh}/bin/nh os switch ~/nixos";
}
