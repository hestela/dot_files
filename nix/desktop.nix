{ config, pkgs, ... }:

{
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

  environment = {
    systemPackages = with pkgs; [
      (pidgin-with-plugins.override { plugins = [ pidginsipe ]; })
      chromium
      ffmpeg
      file
      freerdp
      git
      kde5.plasma-workspace-wallpapers
      libreoffice
      ncurses
      netcat-openbsd
      patchelf
      pavucontrol
      pulseaudioFull
      python27
      python27Packages.pip
      python27Packages.virtualenv
      tmux
      trojita
      unzip
      which
      xscreensaver
    ];
  };
}
