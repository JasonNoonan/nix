# TODO: drop once nixpkgs bumps asdf-vm past 0.20.1.
# Upstream deleted the v0.20.1 tag, so the nixpkgs source fetch 404s.
final: prev: {
  asdf-vm = prev.asdf-vm.overrideAttrs (old: rec {
    version = "0.20.2";
    src = prev.fetchFromGitHub {
      owner = "asdf-vm";
      repo = "asdf";
      rev = "v${version}";
      hash = "sha256-HJRNRA98MIOEF/Q3I+cGUL8kH904j3/msI+FGDbRH7A=";
    };
    vendorHash = "sha256-ompvvNzfJetcKCRueJxXALiN0rOQwSiytTHJcVXFEOo=";
  });
}
