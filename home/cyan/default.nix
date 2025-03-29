{ config, pkgs, lib, ... }:
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
    argocd
    asdf-vm
    docker-compose
    discord
    exercism
    go
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
  home.stateVersion = "24.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

  # k9s
  programs.k9s.enable = true;

  programs.vscode.enable = true;

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    extraConfig = ''Host *
    IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    '';
  };

  programs.git.extraConfig = {
    "gpg \"ssh\"".program = lib.mkOverride 10 "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
  };

  programs.zsh.shellAliases.handshake = "export NIXPKGS_ALLOW_BROKEN=1 && export NIXPKGS_ALLOW_INSECURE=1 && darwin-rebuild switch --flake ~/.config/nix-darwin --impure";
}
