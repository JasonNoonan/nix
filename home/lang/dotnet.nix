{ inputs, pkgs, ... }:
let
  dotnet-full =
    with pkgs.dotnetCorePackages;
    combinePackages [
      sdk_8_0
      runtime_8_0
      aspnetcore_8_0
    ];

  deps = (
    ps:
    with ps;
    [
      rustup
      zlib
      openssl.dev
      pkg-config
      stdenv.cc
      cmake
      mono
      msbuild
    ]
    ++ [ dotnet-full ]
  );
in
{
  home.sessionVariables = {
    DOTNET_ROOT = "${dotnet-full}";
  };

  home.sessionPath = ["$HOME/.dotnet/tools"];

  home.packages = with pkgs; [
    dotnet-full
    pkgs.netcoredbg
  ];
}
