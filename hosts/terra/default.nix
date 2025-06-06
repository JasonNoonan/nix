{ config, lib, pkgs, self, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;
  };

  networking.hostName = "terra"; # Define your hostname.
  # Pick only one of the below networking options.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  networking.networkmanager.wifi.backend = "iwd";  

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    videoDrivers = ["nvidia"];
  };

  hardware.nvidia = {
	    # modesetting.enable = true;
	    open = true;
	    package = config.boot.kernelPackages.nvidiaPackages.beta;
	    nvidiaSettings = true;
	  };

	# hardware.graphics.enable32Bit = false;
	hardware.graphics.enable = true;

  programs.hyprland.enable = true;

  # 1Password
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
  };

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  users.users.jasonnoonan = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      neovim
      git
      tree
    ];
    shell = pkgs.zsh;
    initialPassword = "temp";
    openssh.authorizedKeys.keys = [
	"256 SHA256:w3jvfYquwBoQNSO0egPpNMEvYVCwkafDuJwfmll05kc jason.t.noonan@gmail.com (ED25519)"
	"256 SHA256:b+o5Ym/56EQ92OZq/nNGQSx62yaliN+ijXSUh/mjiUI jason.t.noonan@gmail.com (ED25519)"
    ];
  };


  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Get some boot disk loaders going
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

  environment.systemPackages = with pkgs; [ 
    lutris # windows compatibility
    mangohud # game stats HUD
    vim 
  ];

  nix.settings.experimental-features = "nix-command flakes";

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  # gaming
  programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true;
    package = pkgs.steam.override {
        extraEnv = {
          MANGOHUD = true;
          OBS_VKCAPTURE = true;
          # RADV_TEX_ANISO = 16;
      };

      extraLibraries = p: with p; [
        atk
      ];
    };
  };

  programs.zsh.enable = true;

  programs.coolercontrol = {
    enable = true;
    nvidiaSupport = true;
  };

  # bluetooth

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;

  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;
    openRPCPort = true;
  };

  xdg.portal = {
    config.hyprland = {
      "org.freedesktop.impl.portal.ScreenCast" = "hyprland";
    };
  };

  virtualisation.docker.enable = true;
}
