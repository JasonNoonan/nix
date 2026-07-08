{ pkgs, self, ... }:
{
  environment.systemPackages = [ pkgs.vim ];

  services.nix-daemon.enable = true;

  nix.settings.experimental-features = "nix-command flakes";

  # Enable nix flakes
  nix.package = pkgs.nixVersions.stable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  programs.zsh.enable = true;

  # TODO(nix-darwin#1819): drop both lines once that PR merges, then
  # `nix flake update nix-darwin`. Tracking issue: nix-darwin#1817.
  # nix-darwin's HTML manual builder calls `nixos-render-docs ... --toc-depth`,
  # a flag removed in current nixpkgs-unstable, so darwin-manual-html fails to
  # build. Two independent things pull it into the closure:
  #  1) this system's own docs — skip the HTML manual + darwin-help (man/info
  #     pages stay enabled),
  #  2) darwin-uninstaller, which bundles a *default-config* reference system
  #     (docs on) we can't reach from here — so drop the uninstaller tool too.
  documentation.doc.enable = false;
  system.tools.darwin-uninstaller.enable = false;

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnsupportedSystems = true;
    };

    hostPlatform = "aarch64-darwin";
  };

  # 1Password
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
  };

  users.users.jasonnoonan.home = "/Users/jasonnoonan";

  homebrew = {
    enable = true;
    onActivation =
      {
        autoUpdate = false;
        cleanup = "zap";
        upgrade = true;
      };

    taps = [
      # "homebrew/cask"
    ];

    brews = [
    ];

    casks = [
      "amethyst"
      "geekbench"
      "insomnia"
      "keeper-password-manager"
      "microsoft-edge"
      "notion"
      "obs"
      "postman"
      "steam"
    ];
  };

  networking.hostName = "locke";

  system = {
    defaults = {
      dock.appswitcher-all-displays = true;
      dock.autohide = true;
      dock.showhidden = true;

      trackpad.Clicking = true;
      # sorry stevey, my app switcher demands it
      trackpad.TrackpadThreeFingerDrag = false;
      finder.ShowPathbar = true;
      finder.ShowStatusBar = true;
      loginwindow.GuestEnabled = false;
      loginwindow.autoLoginUser = "jasonnoonan";
      NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
    };

    configurationRevision = self.rev or self.dirtyRev or null;
    stateVersion = 4;
  };
}
