{ config, pkgs, ... }:

{
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/nvme0n1"; # or "nodev" for efi only

  nixpkgs.config = {
    # Nonfree packages (for nvidia drivers)
    allowUnfree = true;
  };

  environment.systemPackages = with pkgs; [
    rxvt_unicode-with-plugins          # Terminal emulator
    wget
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

    extraUsers.hrestela = {
      isNormalUser = true;
      home = "/home/hrestela";

      # Configure for sudo, network, gfx, and docker
      extraGroups = ["wheel" "networkmanager" "docker"];
      uid = 1000;
      shell = "/run/current-system/sw/bin/bash";
    };
  };
}
