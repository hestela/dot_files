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

  services.xserver = {
    enable = true;
    layout = "us";
    desktopManager.kde5.enable = true;
    desktopManager.default = "kde5";
    videoDrivers = [ "nvidia" ];
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
      extraGroups = ["wheel" "networkmanager" "docker"];
      uid = 1000;
      shell = "/run/current-system/sw/bin/bash";
    };
  };

  environment = {
    systemPackages = with pkgs; [
      (pidgin-with-plugins.override { plugins = [ pidginsipe ]; })
      chromium
      clementine
      bind
      ffmpeg
      file
      freerdp
      git
      kde4.ksnapshot
      kde5.plasma-workspace-wallpapers
      libreoffice
      irssi
      ncurses
      netcat-openbsd
      patchelf
      pavucontrol
      pulseaudioFull
      python27
      python27Packages.pip
      python27Packages.redNotebook
      python27Packages.virtualenv
      tmux
      trojita
      unzip
      which
      wget
      xscreensaver
    ];
  };
}
