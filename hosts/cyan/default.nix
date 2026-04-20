{ pkgs, self, ... }:
{
  environment.systemPackages = [ pkgs.vim ];

  nix.settings.experimental-features = "nix-command flakes";

  # Enable nix flakes
  nix.package = pkgs.nixVersions.stable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  system.primaryUser = "jasonnoonan";

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
        autoUpdate = true;
        cleanup = "zap";
        upgrade = true;
      };

    taps = [
      # "homebrew/cask"
      "marcus/tap"
    ];

    brews = [
      "python@3.14"
      "python-tk@3.14"
      "sidecar"
      "td"
    ];

    casks = [
      "1password"
      "amethyst"
      { name = "claude-code"; greedy = true; }
      "discord"
      "docker"
      # "dotnet-sdk@8"
      "firefox"
      "geekbench"
      "ghostty"
      "google-chrome"
      "keeper-password-manager"
      "microsoft-edge"
      "notion"
      "obs"
      "postman"
      "spotify"
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
