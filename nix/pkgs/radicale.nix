with import <nixpkgs> {};

python3Packages.buildPythonApplication rec {

  propagatedBuildInputs = [
    python35
    python35Packages.passlib
    python35Packages.bcrypt
    python35Packages.vobject
  ];

  name = "radicale-${version}";
  version = "2.1.4";

  # Ignore failing tests
  doCheck = false;

  src = fetchurl {
    url = "mirror://pypi/R/Radicale/Radicale-${version}.tar.gz";
    sha256 = "0bkydhgfqzhpprf1l9vdxzwsvirsigkcajw53vrwxzaya5in61f4";
  };
}
