with import <nixpkgs> {};

python2Packages.buildPythonApplication rec {

  propagatedBuildInputs = [
    python27
    python27Packages.pyyaml
  ];

  name = "clustershell-${version}";
  version = "v1.8.1";

  src = fetchurl {
    url = "https://github.com/cea-hpc/clustershell/archive/${version}.tar.gz";
    sha256 = "030haydvj81fin5jmvlshhsa5140rn6mp45m81gp72yy11qshg8c";
  };
}
