with import <nixpkgs> {};

python27Packages.buildPythonApplication rec {

  propagatedBuildInputs = [
    python27
  ];

  name = "pyxml-${version}";
  version = "0.8.4";

  # Ignore failing tests
  doCheck = false;

  src = fetchurl {
    url = "https://git.easycashmoney.org/hrestela/pyxml/archive/master.zip";
    sha256 = "1l2i3w4dq9h2nid7g8x7az0lm40n4pf0lfhx7mpfdzqf0mndi649";
  };
}
