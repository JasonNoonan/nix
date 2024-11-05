{ config, pkgs, ... }:
{
  imports = [
    ../git.nix
    ../kitty.nix
    ../lang/dotnet.nix
    ../lang/elixir.nix
    ../lang/yaml.nix
    ../neovim
    ../shell.nix
    ../tmux
  ];

  home.packages = with pkgs; [
    docker-compose
    discord
    go-task
    (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.kubectl google-cloud-sdk.components.gke-gcloud-auth-plugin google-cloud-sdk.components.bq ])
    slack
    zoom-us
  ];

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

  # k9s
  programs.k9s.enable = true;

  programs.vscode.enable = true;

  programs.ssh = {
    enable = true;

    matchBlocks = {
      locke = {
        hostname = "locke.lan";
        forwardAgent = true;
        localForwards = [
          {
            bind.port = 4000;
            host.address = "localhost";
            host.port = 4000;
          }
        ];
      };
    };
  };

  programs.zsh.shellAliases.handshake = "darwin-rebuild switch --flake ~/.config/nix-darwin";
}
