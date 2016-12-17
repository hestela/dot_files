{ config, pkgs, ... }:

{

  services.xserver.enable = true;
  services.xserver.desktopManager.kde4.enable = true;

  networking = {
    hostName = "moola";
  };

  environment = {
    variables = {
      EDITOR = "vim";
    };

    systemPackages = with pkgs; [
      git                                # Git source control
      python27                           # Python programming language
      python27Packages.pip               # Python package manager
      python27Packages.virtualenv
      which                              # Dependency for fzf.vim
    ];
  };
}
