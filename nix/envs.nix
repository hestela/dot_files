# Invoke with: nix-shell envs.nix -A rhel7
let
  pkgs = import <nixpkgs> {};
  stdenv = pkgs.stdenv;
  common = with pkgs; [
    autoconf
    automake
    libtool
    python27Full
  ];
in rec {
  rhel7 = stdenv.mkDerivation rec {
    name = "rhel7";
    version = "1.0";
    src = ./.;
    # Default nix opt flags dont work in gcc 4.8
    hardeningDisable = [ "all" ];
    buildInputs = with pkgs; [
      gcc48
      gnumake381
      openssl
      rpm
    ] ++ common;
  };
  gcc4_9 = stdenv.mkDerivation rec {
    name = "gcc4_9";
    version = "1.0";
    src = ./.;
    buildInputs = with pkgs; [
      bc
      gcc49
      gnumake381
      openssl
    ] ++ common;
  };
}
