with import <nixpkgs> {};

python3Packages.buildPythonApplication rec {

  name = "cppclean-${version}";
  version = "0.12";

  # faster build
  doCheck = false;

  src = fetchurl {
    url = "mirror://pypi/c/cppclean/cppclean-${version}.tar.gz";
    sha256 = "05p0qsmrn3zhp33rhdys0ddn8hql6z25sdvbnccqwps8jai5wq2r";
  };
}
