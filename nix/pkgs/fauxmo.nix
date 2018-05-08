with import <nixpkgs> {};

python3Packages.buildPythonApplication rec {

  propagatedBuildInputs = [
    python36
    python36Packages.requests
    (import ./pypandoc.nix)
  ];

  name = "fauxmo-${version}";
  version = "0.4.7";

  doCheck = false;

  src = fetchgit {
    url = "https://github.com/hestela/fauxmo";
    rev = "49d2c57058feab7b586b5d8212f93beeec5283a7";
    sha256 = "0j94drxsvbirvjbczqx7r4gajwch5brdasgsav38fr4lrnv2r5mw";
  };
}
