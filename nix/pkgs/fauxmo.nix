with import <nixpkgs> {};

python3Packages.buildPythonApplication rec {

  propagatedBuildInputs = [
    python38
    python38Packages.requests
    (import ./pypandoc.nix)
  ];

  name = "fauxmo-${version}";
  version = "v0.4.7";

  doCheck = false;

  src = fetchgit {
    url = "https://github.com/n8henrie/fauxmo";
    rev = "${version}";
    sha256 = "0dbk6c9lljrcq890899ybh9yhyjjhrfkmqyb99vyhp36m10vjx0s";
  };
}
