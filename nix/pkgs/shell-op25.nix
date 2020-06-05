# nix-shell expression to make running op25 easier
with import <nixpkgs> {};
let
  op25 = (import ./op25.nix);
in
  stdenv.mkDerivation {
  shellHook = ''
    export PYTHONPATH="${op25}/lib/python2.7/site-packages/:$PYTHONPATH"
    export LD_LIBRARY_PATH="${op25}/lib:$LD_LIBRARY_PATH"
    export OP25="${op25}/bin/gr-op25_repeater/apps/"
  '';
  name = "env";
  buildInputs = [
    boost
    cppunit
    doxygen
    gnuradio
    gr-osmosdr
    hackrf
    libpcap
    rtl-sdr
    swig
    uhd
    python27
    python27Packages.numpy
    python27Packages.waitress
    python27Packages.requests
  ];
}
