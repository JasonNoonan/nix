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
