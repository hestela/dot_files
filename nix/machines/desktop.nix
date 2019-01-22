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
    bluetooth.enable = false;
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
      fetchTarball https://github.com/NixOS/nixpkgs/archive/master.tar.gz
      #fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz
    )
    # Spotify is non-free
    {
      config.allowUnfree = true;
    };
    in
    with pkgs; [
      (curl.override { gssSupport = true; })
      (import ../pkgs/bible.nix)
      (import ../pkgs/clementine.nix)
      (pidgin-with-plugins.override { plugins = [ pidginsipe ]; })
      (discord.overrideAttrs (oldAttrs: rec {
        src = fetchurl {
          url = "https://dl.discordapp.net/apps/linux/0.0.6/discord-0.0.6.tar.gz";
          sha256 = "1xy2d4gqixy6cchacxkx1pynavsgp49mg763ic9hld51a4nlibs4";
        };
      }))
      bind
      chromium
      discord
      ffmpeg
      file
      freerdp
      git
      git-review
      gnome3.gnome-calculator
      gnumake
      gnutls
      gparted
      gss
      hexchat
      irssi
      jre
      krb5Full
      ksuperkey
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
      plasma-nm
      plasma-workspace-wallpapers
      psmisc
      pulseaudioFull
      python27
      python27Packages.pip
      python27Packages.virtualenv
      python3
      python36Packages.flake8
      python36Packages.lxml
      python36Packages.pymongo
      pkgsUnstable.steam
      rednotebook
      rpm
      tmux
      trojita
      unzip
      usbutils
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
