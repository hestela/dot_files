{ config, pkgs, ... }:
{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nixpkgs.config = {
    allowUnfree = true;
  };

  fonts = {
    fonts = with pkgs; [
      ubuntu_font_family
    ];
  };

  # No idea why i need this
  #nixpkgs.config.permittedInsecurePackages = [
  #  "webkitgtk-2.4.11"
  #];

  networking = {
    hostName = "cash";
    wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    enableB43Firmware = true;
  };

  services.xserver = {
    enable = true;
    layout = "us";
    desktopManager.plasma5.enable = true;
    desktopManager.default = "plasma5";

    # Enable touchpad support.
    libinput.enable = true;
  };

  # Enable yubikey
  services.pcscd.enable = true;
  services.udev.packages = [
    pkgs.libu2f-host
    pkgs.yubikey-personalization
  ];

  services.samba = {
    enable = true;
    nsswins = true;
  };

  hardware = {
    opengl.driSupport32Bit = true;
    pulseaudio.enable = true;
    pulseaudio.support32Bit = true;
  };

  users = {
    defaultUserShell = "/run/current-system/sw/bin/bash";

    extraUsers.henry= {
      isNormalUser = true;
      home = "/home/henry";

      # Configure for sudo, network, gfx, and docker
      extraGroups = ["wheel" "networkmanager" "docker"];
      shell = "/run/current-system/sw/bin/bash";
      uid = 1000;
    };
  };

  environment = {
    systemPackages = let pkgsUnstable = import
    (
      fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz
    )
    # Spotify is non-free
    { config.allowUnfree = true; };
    in
    with pkgs; [
      (import ../pkgs/bible.nix)
      chromium
      ffmpeg
      file
      freerdp
      git
      gnome3.gnome-calculator
      gnumake
      gnutls
      gparted
      google-drive-ocamlfuse
      gss
      gphoto2
      hexchat
      htop
      jre
      krb5Full
      libreoffice
      libu2f-host
      ncurses
      netcat-openbsd
      ntp
      openssl
      patchelf
      pavucontrol
      pciutils
      pcsctools
      clementine
      #pkgsUnstable.clementine
      plasma-nm
      plasma-workspace-wallpapers
      psmisc
      pulseaudioFull
      python27
      python27Packages.pip
      # Broken on 26, missing package on 36
      pkgsUnstable.python36Packages.redNotebook
      python27Packages.virtualenv
      python34
      python35Packages.flake8
      tmux
      unzip
      wget
      which
      xclip
      xmlstarlet
      xscreensaver
      yubikey-personalization
      zlib
    ];
  };
}
