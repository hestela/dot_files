{ config, pkgs, ... }:

{
  # Use gummiboot
  boot.loader.gummiboot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.firewall.allowedTCPPorts = [ 80 443 3000 8888 42063 8000 ];
  networking.firewall.allowedUDPPorts = [ 80 443 3000 8888 42063 8000 ];

  nixpkgs.config = {
    # Nonfree packages (for nvidia drivers)
    allowUnfree = true;
  };

  environment.systemPackages = with pkgs; [
    powertop # See power consumption
    pavucontrol
    byzanz
    ffmpeg-full                        # Video recording/converting/streaming
    htop                               # System monitor
    irssi                              # Irc client
    nix-repl                           # Repl for nix package manager
    pulseaudioFull                     # Audio
    rxvt_unicode-with-plugins          # Terminal emulator
    scrot                              # Screenshot capturing
    sshfsFuse                          # FS over SSH
    tmux                               # Console multiplexer
    tree                               # File tree
    unzip                              # .zip file util
    wget
    transmission
  ];


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

    extraGroups.ssl-cert.gid = 1040;

    extraUsers.henry = {
      isNormalUser = true;
      home = "/home/henry";

      # Configure for sudo, network, gfx, and docker
      extraGroups = ["wheel" "networkmanager" "docker" "ssl-cert" "essentials" ];
      uid = 1000;
      shell = "/run/current-system/sw/bin/bash";
    };
  };
}
