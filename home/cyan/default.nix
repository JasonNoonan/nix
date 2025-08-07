{ config, inputs, pkgs, lib, ... }:
{
  imports = [
    ../claude
    ../git.nix
    ../kitty.nix
    ../lang
    ../lang/dotnet.nix
    ../lang/elixir.nix
    ../lang/yaml.nix
    ../neovim
    ../opencode
    ../shell.nix
    ../tmux
  ];

  home.packages = with pkgs; [
    argocd
    asdf-vm
    bun
    docker-compose
    discord
    exercism
    firefox
    gitleaks
    go
    go-task
    (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.kubectl google-cloud-sdk.components.gke-gcloud-auth-plugin google-cloud-sdk.components.bq ])
    graphite-cli
    inputs.mcp-hub.packages."${system}".default
    kubernetes-helm
    node-gyp
    playwright
    playwright-driver.browsers
    python312
    python312Packages.pillow
    python312Packages.pytesseract
    python312Packages.setuptools
    slack
    tesseract
    uv
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

  home = {
    sessionVariables = {
      CC = "${pkgs.llvmPackages_20.libcxxClang}/clang";
      CXX = "${pkgs.llvmPackages_20.libcxxClang}/clang++";
    };
    sessionPath = ["$HOME/.bun/bin" "/opt/local/bin" "/opt/local/sbin" "$HOME/.npm-packages/bin"];
    file.".npmrc".source = ../npm/.npmrc;
  };

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
