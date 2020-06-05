with import <nixpkgs> {};
let
  ld_library_path = builtins.concatStringsSep ":" [
    "${stdenv.cc.cc.lib}/lib64"
    (stdenv.lib.makeLibraryPath [
      blas
      liblapack
    ])
  ];
in

stdenv.mkDerivation rec {
  version = "4.3.1";

  src = fetchurl {
    url = "mirror://sourceforge/itpp/itpp-4.3.1.tar.bz2";
    sha256 = "0xxqag9wi0lg78xgw7b40rp6wxqp5grqlbs9z0ifvdfzqlhpcwah";
  };
  enableParallelBuilding = true;

  nativeBuildInputs = [ cmake pkgconfig makeWrapper automake libtool ];

  buildInputs = [
    fftw
    liblapack
    blas
  ];

  #postPatch = ''
  #  sed -i src/CMakeLists.txt \
  #    -e 's,-Werror,,g' \
  #    -e 's,-Wno-unknown-warning-option,,g' \
  #    -e 's,-Wno-unused-private-field,,g'
  #'';

  name = "itpp-${version}";


  cmakeFlags = [ "-DLD_LIBRARY_PATH=${ld_library_path}" ];


    # Hack to repair missing gst plugins errors
    #postInstall = ''
    #  wrapProgram $out/bin/clementine \
    #    --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${pkgs.gst_all_1.gst-plugins-good}/lib/gstreamer-1.0/:${pkgs.gst_all_1.gst-plugins-base}/lib:${pkgs.gst_all_1.gstreamer}/lib:${pkgs.gst_all_1.gst-plugins-bad}/lib"
    #'';
}
