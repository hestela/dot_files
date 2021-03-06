{ config, pkgs, ... }:

{
  console.font = "lat9w-16";
  console.keyMap = "us";
  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  # Set sudo to use user home
  security.sudo.extraConfig = ''
    Defaults !always_set_home
    Defaults env_keep+="HOME"
  '';

  time.timeZone = "US/Pacific";
  programs.bash.enableCompletion = true;

  networking.enableIPv6 = false;
  #networking.nameservers = [ "8.8.8.8" ];

  boot.cleanTmpDir = true;
  boot.tmpOnTmpfs = true;
}
