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
    ../mcphub
    ../neovim
    ../shell.nix
    ../tmux
  ];

  home = {
    username = "jasonnoonan";
    homeDirectory = "/home/jasonnoonan";
    stateVersion = "23.11";
    packages = with pkgs; [
      asciidoctor-with-extensions
      asdf
      browsh
      bun
      claude-code
      docker
      docker-compose
      exercism
      firefox
      gdk
      go
      graphviz
      jre8
      kubernetes
      lazydocker
      opencode
      python312Packages.pillow
      python313
      python313Packages.pytesseract
      rsync
      ruby
      rubyPackages_3_4.rouge
      taskwarrior3
      tesseract
      xdg-utils
    ];
  };

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

  # k9s
  programs.k9s.enable = true;


  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    matchBlocks = {
      "github.com" = { };
      "pdq" =
        {
          hostname = "192.168.86.30";
          user = "jasonnoonan";
          dynamicForwards = [{ port = 8081; }];

          localForwards = [
            # default elixir port
            {
              bind.port = 4000;
              host.address = "localhost";
              host.port = 4000;
            }

            # postgres for ash testing
            {
              bind.port = 5434;
              host.address = "localhost";
              host.port = 5434;
            }
          ];

          forwardAgent = true;
        };
    };
  };
  programs.vscode.enable = true;

  programs.zsh.shellAliases.handshake = "${pkgs.nh}/bin/nh os switch ~/nixos";
}
