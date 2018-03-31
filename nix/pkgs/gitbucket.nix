with import <nixpkgs> {};

stdenv.mkDerivation rec {

  name = "gitbucket-${version}";
  version = "4.22.0";

  src = fetchurl {
    url = "https://github.com/gitbucket/gitbucket/releases/download/${version}/gitbucket.war";
    sha256 = "0isxann89dxr822mnd1s795xd9jwja1j52r236nx0c2aq32ykzlw";
  };

  buildCommand = ''
  mkdir -p "$out/"
  cp "$src" "$out/gitbucket.war"
  '';
}
