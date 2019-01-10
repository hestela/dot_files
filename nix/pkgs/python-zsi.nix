with import <nixpkgs> {};

python2Packages.buildPythonApplication rec {

  propagatedBuildInputs = [
    python27
    python27Packages.lxml
    python27Packages.beautifulsoup4
    (import ./pyxml.nix)
  ];

  version = "2.0-rc3";
  name = "python-zsi-${version}";

  doCheck = false;

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/bb/3b/b2053649e156f2a428cb57999d0361686d8f0f6841987588bef3c5ea0c8c/ZSI-2.0-rc3.tar.gz";
    sha256 = "0wbc7v4cdzayk58xh7kzfgirqr69b57z5y0359p7sbqb5s7zz68n";
  };

}
