with import <nixpkgs> {};

python2Packages.buildPythonApplication rec {

  propagatedBuildInputs = [
    python27
  ];

  name = "pxeconfig-${version}";
  version = "1.0";

  src = fetchTarball {
    url = "http://bones.corp.easycashmoney.org/pxeconfig.tar.gz";
    sha256 = "0xaa0jryi11mi0pq5304a42pc5q09qfdp5sjsph0s6zn6wyc23ci";
  };
}
