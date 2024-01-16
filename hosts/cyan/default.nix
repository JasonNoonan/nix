{ pkgs, self, ... }:
{
  environment.systemPackages = [ pkgs.vim ];

  services.nix-daemon.enable = true;

  nix.settings.experimental-features = "nix-command flakes";

  # Enable nix flakes
  nix.package = pkgs.nixFlakes;
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
      "1password"
      "amethyst"
      "docker"
      "inkscape"
      "keeper-password-manager"
      "microsoft-edge"
      "notion"
      "obs"
      "postman"
    ];
  };

  networking.hostName = "cyan";

  system = {
    defaults = {
      dock.appswitcher-all-displays = true;
      dock.autohide = true;
      dock.showhidden = true;

      trackpad.Clicking = true;
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
