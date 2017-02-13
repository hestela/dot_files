with import <nixpkgs> {};

python3Packages.buildPythonApplication rec {

  propagatedBuildInputs = [
    python35
    python35Packages.requests2
  ];

  name = "fauxmo-${version}";
  version = "0.3.2";

  # No module named tests
  doCheck = false;

  # Not going to use homeassistant
  patches = [ ./patches/Disable-homeassistant.patch ./patches/Disable-logging.patch ];

  src = fetchurl {
    url = "https://pypi.python.org/packages/3a/8a/fa2b18a59ec7925651c6d11c319c0c3373a4b898697850bb210f9e2b85f9/fauxmo-${version}.tar.gz";
    sha256 = "1lwim612yp9ji6jbxawp402f49hqd22xllycb1a4z37gzysdqsx2";
  };
}
