{ config, pkgs, ... }:
{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
  };

  fonts = {
    fonts = with pkgs; [
      ubuntu_font_family
    ];
  };

  networking = {
    hostName = "cash";
    enableB43Firmware = true;
    # temp fix
    #enableIPv6 = false;
    #networkmanager.enable = false;
    #wireless.enable = true;
    networkmanager.enable = true;
    # Add ipv6 dns for some public wifi that dont give good dns servers
    nameservers = [ "8.8.8.8" "2001:67c:2b0::4"];
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
    bluetooth.enable = true;
    bluetooth.extraConfig = ''
      [general]
      Enable=Source,Sink,Media,Socket
    '';
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
    #(
    #  fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz
    #)
    # Spotify is non-free
    {
      config.allowUnfree = true;
    };
    in
    with pkgs; [
      snes9x-gtk
      mgba
      # crappy term umu
      fceux
      retroarch

      # exfat support
      exfat-utils

      (import ../pkgs/bible.nix)
      (import ../pkgs/emulationstation.nix)
      emulationstation
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
      #pkgsUnstable.python36Packages.redNotebook
      python27Packages.virtualenv
      python34
      python35Packages.flake8
      sshuttle
      tmux
      unzip
      wget
      which
      xclip
      xmlstarlet
      xscreensaver
      yubikey-personalization
      zlib
      darktable
    ];
  };
}
