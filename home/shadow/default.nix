{ config, inputs, pkgs, ... }:
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
    ../opencode.nix
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
      claude-code
      docker
      docker-compose
      exercism
      firefox
      gdk
      go
      graphviz
      inputs.mcp-hub.packages."${system}".default
      jre8
      kubernetes
      lazydocker
      python312Packages.pillow
      python313
      python313Packages.pytesseract
      rsync
      ruby
      rubyPackages_3_4.rouge
      taskwarrior3
      tesseract
      unzip
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
