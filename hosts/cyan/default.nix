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
      "td"
    ];

    casks = [
      "1password"
      "amethyst"
      { name = "claude-code@latest"; greedy = true; }
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
      "supacode"
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
