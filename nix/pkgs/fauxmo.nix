with import <nixpkgs> {};

python3Packages.buildPythonApplication rec {

  propagatedBuildInputs = [
    python36
    python36Packages.requests
    (import ./pypandoc.nix)
  ];

  name = "fauxmo-${version}";
  version = "0.4.6";

  doCheck = false;

  src = fetchurl {
    url = "mirror://pypi/f/fauxmo/fauxmo-${version}.tar.gz";
    sha256 = "1j0h7rrj1r2vvv74s1ldqc9ipx7qbvmknkmxlcpsy35pklkb7a1k";
  };
}
