with import <nixpkgs> {};

python2Packages.buildPythonApplication rec {

  propagatedBuildInputs = [
    python27
    python27Packages.lxml
    python27Packages.beautifulsoup4
  ];

  name = "bible-${version}";
  version = "1.0";

  # Ignore failing tests
  doCheck = false;

  src = fetchgit {
    url = "http://gitlab.easycashmoney.org/hrestela/bgate.git";
    rev = "74a52d0a8acbfcf9ca401ae300d137394fefb03c";
    sha256 = "1k6w711283a34j2yc2j0b8j245j51ddr8sky2r5bjwiz27r37zi9";
  };
}
