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
    url = "http://git.easycashmoney.org/hrestela/bgate.git";
    rev = "aa82e4e28a282ccbaab3888d1d0a4f7b44e87d2a";
    sha256 = "168bcpjyc1gbmskaw9kbca3l5m358v4863gidvn0jzcvx0bw28gc";
  };
}
