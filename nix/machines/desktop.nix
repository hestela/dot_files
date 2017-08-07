{ config, pkgs, ... }:

{
  # Using BIOS boot
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/nvme0n1"; # or "nodev" for efi only

  nixpkgs.config = {
    # Nonfree packages (for nvidia drivers)
    allowUnfree = true;
  };

  fonts = {
    fonts = with pkgs; [
      ubuntu_font_family
    ];
  };

  # No idea why i need this
  nixpkgs.config.permittedInsecurePackages = [
    "webkitgtk-2.4.11"
  ];

  services.xserver = {
    enable = true;
    layout = "us";
    desktopManager.plasma5.enable = true;
    desktopManager.default = "plasma5";
    videoDrivers = [ "nvidia" ];
  };

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

    extraUsers.hrestela = {
      isNormalUser = true;
      home = "/home/hrestela";

      # Configure for sudo, network, gfx, and docker
      extraGroups = ["wheel" "networkmanager" "docker" "user" "fabdev"];
      shell = "/run/current-system/sw/bin/bash";
    };
  };

  networking = {
    networkmanager.enable = true;
  };

  environment = {
    systemPackages = with pkgs; [
      (curl.override { gssSupport = true; })
      (pidgin-with-plugins.override { plugins = [ pidginsipe ]; })
      bind
      chromium
      clementine
      davmail
      ffmpeg
      file
      freerdp
      git
      git-review
      gnumake380
      gnutls
      gparted
      gss
      irssi
      jre
      plasma-nm
      plasma-workspace-wallpapers
      krb5Full
      libreoffice
      ncurses
      netcat-openbsd
      ntp
      openssl
      patchelf
      pavucontrol
      pciutils
      pulseaudioFull
      python27
      python27Packages.pip
      python27Packages.redNotebook
      python27Packages.virtualenv
      python34
      python35Packages.flake8
      tmux
      trojita
      unzip
      wget
      which
      xmlstarlet
      xscreensaver
      zlib
      gnome3.gnome-calculator
      ntfs3g
      hexchat
    ];
  };
}
