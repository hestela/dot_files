with import <nixpkgs> {};

python3Packages.buildPythonApplication rec {

  propagatedBuildInputs = [
    python36Full
    python36Packages.aiohttp
    python36Packages.websockets
  ];

  name = "discord.py-${version}";
  version = "0.16.12";
  doCheck = false;

  postPatch = ''
    #substituteInPlace requirements.txt --replace '1.0.0,<1.1.0' '3.5.0'
    echo "" > requirements.txt
  '';

  src = fetchurl {
    url = "mirror://pypi/d/discord.py/${name}.tar.gz";
    sha256 = "0201sl3p8z19zsad2jpapgrwxdjd30ra9fk8jjkzgfhg20a8iyqp";
  };
}
