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
    systemPackages = let pkgsUnstable = import
    (
      fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz
    )
    # Spotify is non-free
    { config.allowUnfree = true; };
    in
    with pkgs; [
      (curl.override { gssSupport = true; })
      (pidgin-with-plugins.override { plugins = [ pidginsipe ]; })
      bind
      chromium
      davmail
      ffmpeg
      file
      freerdp
      git
      git-review
      gnome3.gnome-calculator
      gnumake380
      gnutls
      gparted
      gss
      hexchat
      irssi
      jre
      krb5Full
      libreoffice
      libu2f-host
      ncurses
      netcat-openbsd
      ntfs3g
      ntp
      openssl
      patchelf
      pavucontrol
      pciutils
      pcsctools
      pkgsUnstable.clementine
      plasma-nm
      plasma-workspace-wallpapers
      psmisc
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
      xclip
      xmlstarlet
      xscreensaver
      yubikey-personalization
      zlib
    ];
  };
}
