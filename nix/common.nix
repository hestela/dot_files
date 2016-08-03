{ config, pkgs, ... }:

{
  # Use gummiboot
  boot.loader.gummiboot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      ubuntu_font_family # Ubuntu fonts
      liberation_ttf
    ];
  };

  networking.firewall.allowedTCPPorts = [ 80 3000 8888 42063 4040 ];
  networking.firewall.allowedUDPPorts = [ 80 3000 8888 42063 4040 ];

  nixpkgs.config = {
    # Nonfree packages (for nvidia drivers)
    allowUnfree = true;
  };

  environment.systemPackages = with pkgs; [
    powertop # See power consumption
    pinta      #simple paint program
    gutenprint # printer
    gutenprintBin # more printer
    pavucontrol
    byzanz
    ffmpeg-full                        # Video recording/converting/streaming
    htop                               # System monitor
    irssi                              # Irc client
    live555                            # RTSP libs for
    mplayer                            # Video player
    nix-repl                           # Repl for nix package manager
    pulseaudioFull                     # Audio
    rxvt_unicode-with-plugins          # Terminal emulator
    scrot                              # Screenshot capturing
    skype
    sshfsFuse                          # FS over SSH
    tmux                               # Console multiplexer
    transmission                       # Bittorrent Client
    tree                               # File tree
    unzip                              # .zip file util
    vlc
    wget
  ];


  hardware = {
    # Enable audio
    pulseaudio.enable = true;

    # Enable bluetooth
    bluetooth.enable = true;
  };

  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set sudo to use user home
  security.sudo.extraConfig = ''
    Defaults !always_set_home
    Defaults env_keep+="HOME"
  '';

  time.timeZone = "US/Pacific";

  users = {
    defaultUserShell = "/run/current-system/sw/bin/bash";

    extraUsers.henry = {
      isNormalUser = true;
      home = "/home/henry";

      # Configure for sudo, network, gfx, and docker
      extraGroups = ["wheel" "networkmanager" "video" "docker"];
      uid = 1000;
      shell = "/run/current-system/sw/bin/bash";
    };
  };
}
