with import <nixpkgs> {};
#let
#  ld_library_path = builtins.concatStringsSep ":" [
#    "${stdenv.cc.cc.lib}/lib64"
#    (stdenv.lib.makeLibraryPath [
#      blas
#      liblapack
#    ])
#  ];
#in

stdenv.mkDerivation rec {
  version = "1.0";

  src = fetchgit {
    url = "git://git.osmocom.org/op25";
    rev = "0686f2de147688ebb5cf2e2fc027af9bef47d8c1";
    sha256 = "0nlvmwhvw46z45cgzlscyzishdm5mrxkyrmgm49kikwvsscsl8xz";
  };
  enableParallelBuilding = true;

  nativeBuildInputs = [ cmake_2_8 pkgconfig makeWrapper automake libtool ];

  buildInputs = [
    (import ./itpp.nix)
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

  #postPatch = ''
  #  sed -i src/CMakeLists.txt \
  #    -e 's,-Werror,,g' \
  #    -e 's,-Wno-unknown-warning-option,,g' \
  #    -e 's,-Wno-unused-private-field,,g'
  #'';

  cmake = pkgs.cmake_2_8;
  name = "op25-${version}";
  postInstall = ''
    mkdir -p $out/bin
    cp -r $src/op25/gr-op25_repeater $out/bin
    '';


  #cmakeFlags = [ "-DLD_LIBRARY_PATH=${ld_library_path}" ];


    # Hack to repair missing gst plugins errors
    #postInstall = ''
    #  wrapProgram $out/bin/clementine \
    #    --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${pkgs.gst_all_1.gst-plugins-good}/lib/gstreamer-1.0/:${pkgs.gst_all_1.gst-plugins-base}/lib:${pkgs.gst_all_1.gstreamer}/lib:${pkgs.gst_all_1.gst-plugins-bad}/lib"
    #'';
}
