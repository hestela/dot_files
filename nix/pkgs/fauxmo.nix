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
    rev = "f2246b952a0246bf0dcd74e770c9daea0dcaa763";
    sha256 = "0mfmbs09irh39ldak55lzsai9j3wmf0zwi0javnna6xkb2j1yh2i";
  };
}
