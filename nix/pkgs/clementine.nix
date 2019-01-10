with import <nixpkgs> {};

stdenv.mkDerivation rec {
  # No new tags for clementine in a long time
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "clementine-player";
    repo = "Clementine";
    rev = "107e9458724185314c576e49de45aeb28fcc814d";
    sha256 = "1mb2pgg7zjc2d0qq53f6nz91i54ky9cvq901khkvfj9qqbbhhi22";
  };
  enableParallelBuilding = true;

  patches = [
    patches/clementine-spotify-blob.patch
    # Required so as to avoid adding libspotify as a build dependency (as it is 
    # unfree and thus would prevent us from having a free package).
    patches/clementine-spotify-blob-remove-from-build.patch
  #  (fetchpatch {
  #    # Fix w/gcc7
  #    url = "https://github.com/clementine-player/Clementine/pull/5630.patch";
  #    sha256 = "0px7xp1m4nvrncx8sga1qlxppk562wrk2qqk19iiry84nxg20mk4";
  #  })
  ];

  nativeBuildInputs = [ cmake pkgconfig makeWrapper ];

  buildInputs = [
    boost
    chromaprint
    fftw
    gettext
    glew
    # These gst_all_1 pkgs need to getr added to the plugin path
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-bad
    gst_all_1.gstreamer
    gvfs
    libechonest
    liblastfm
    libpulseaudio
    pcre
    projectm
    protobuf
    qca2
    qjson
    qt4
    sqlite
    taglib
  ];

  postPatch = ''
    sed -i src/CMakeLists.txt \
      -e 's,-Werror,,g' \
      -e 's,-Wno-unknown-warning-option,,g' \
      -e 's,-Wno-unused-private-field,,g'
    sed -i CMakeLists.txt \
      -e 's,libprotobuf.a,protobuf,g'
  '';

    name = "clementine-free-${version}";


    cmakeFlags = [ "-DUSE_SYSTEM_PROJECTM=ON" ];


    # Hack to repair missing gst plugins errors
    postInstall = ''
      wrapProgram $out/bin/clementine \
        --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${pkgs.gst_all_1.gst-plugins-good}/lib/gstreamer-1.0/:${pkgs.gst_all_1.gst-plugins-base}/lib:${pkgs.gst_all_1.gstreamer}/lib:${pkgs.gst_all_1.gst-plugins-bad}/lib"
    '';

    meta = with stdenv.lib; {
      homepage = http://www.clementine-player.org;
      description = "A multiplatform music player";
      license = licenses.gpl3Plus;
      platforms = platforms.linux;
      maintainers = [ maintainers.ttuegel ];
    };
}
