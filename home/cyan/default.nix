{ config, inputs, pkgs, lib, ... }:
{
  imports = [
    ../git.nix
    ../kitty.nix
    ../lang
    ../lang/dotnet.nix
    ../lang/elixir.nix
    ../lang/yaml.nix
    ../mcphub
    ../neovim
    ../opencode.nix
    ../shell.nix
    ../tmux
  ];

  home.packages = with pkgs; [
    argocd
    asdf-vm
    claude-code
    docker-compose
    discord
    exercism
    firefox
    go
    go-task
    (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.kubectl google-cloud-sdk.components.gke-gcloud-auth-plugin google-cloud-sdk.components.bq ])
    inputs.mcp-hub.packages."${system}".default
    nodejs_22
    python312
    python312Packages.pillow
    python312Packages.pytesseract
    slack
    tesseract
  ];

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";


  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

  # k9s
  programs.k9s.enable = true;

  programs.vscode.enable = true;

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        identityFile = [ "/Users/jasonnoonan/.ssh/id_ed25519" ];
      };
    };
  };

  programs.zsh.shellAliases.handshake = "export NIXPKGS_ALLOW_BROKEN=1 && export NIXPKGS_ALLOW_INSECURE=1 && sudo darwin-rebuild switch --flake ~/.config/nix-darwin --impure";
}
