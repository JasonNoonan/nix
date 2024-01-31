{ inputs, pkgs, ... }:

{
  home.sessionVariables = {
    DOTNET_ROOT = "${pkgs.dotnet-sdk_6}";
  };

  home.sessionPath = ["$HOME/.dotnet/tools"];

  home.packages = with pkgs; [
    pkgs.dotnet-sdk_6
    pkgs.netcoredbg
  ];
}
