with import <nixpkgs> {};

python3Packages.buildPythonApplication rec {

  propagatedBuildInputs = [
    python36
    python36Packages.requests
    (import ./pypandoc.nix)
  ];

  name = "fauxmo-${version}";
  version = "0.4.8";

  doCheck = false;

  src = fetchgit {
    url = "https://github.com/n8henrie/fauxmo";
    rev = "0bc916d3edca6572edb7325ba3803d313dea9ce9";
    sha256 = "0j94drxsvbirvjbczqx7r4gajwch5brdasgsav38fr4lrnv2r5mw";
  };
}
