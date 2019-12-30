{ pkgs ? import <nixpkgs> {}
, compiler ? "ghc865"
}:

pkgs.haskell.packages.${compiler}.callCabal2nix "hinit" ./. {}
