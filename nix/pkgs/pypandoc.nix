with import <nixpkgs> {};

python3Packages.buildPythonApplication rec {

  propagatedBuildInputs = [
    pkgs.pandoc
    python36
  ];

  name = "-${version}";
  version = "1.4";
  doCheck = false;

  src = fetchurl {
    url = "mirror://pypi/p/pypandoc/pypandoc-${version}.tar.gz";
    sha256 = "0nqsq43jzjf2f8w2kdfby0jqfc33knq0kng4hx47cxjaz3ayc579";
  };
}
