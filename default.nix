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

  system.configurationRevision = self.rev or self.dirtyRev or null;

  system.stateVersion = 4;

  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.jasonnoonan.home = "/Users/jasonnoonan";
}
