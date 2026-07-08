# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, ... }:

{
  imports = [
    # include NixOS-WSL modules
  ];

  wsl.enable = true;
  wsl.defaultUser = "jasonnoonan";

  environment.systemPackages = [
    pkgs.linuxPackages.usbip
  ];


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  nixpkgs.config = {
    allowUnfree = true;
  };

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  users.users.jasonnoonan = {
    isNormalUser = true;
    initialPassword = "test123";
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
  };

  networking = {
    hostName = "shadow";

    firewall.enable = false;
  };

  # Resolve .local hostnames (e.g. cyan.local) dynamically via mDNS.
  # Equivalent to `apt install avahi-daemon libnss-mdns` plus adding
  # `mdns4_minimal` to /etc/nsswitch.conf on a Debian/WSL system:
  # `nssmdns4 = true` wires mdns_minimal into nsswitch for name resolution.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  programs.zsh.enable = true;

  virtualisation.docker.enable = true;
}
