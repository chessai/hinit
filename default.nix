{ pkgs ? import <nixpkgs> {}
, compiler ? "ghc865"
}:

rec {
  inherit pkgs;
  hsPkgs = pkgs.haskell.packages.${compiler};
  hinit = hsPkgs.callCabal2nix "hinit" ./. {};
}
