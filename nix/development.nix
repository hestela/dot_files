{ config, pkgs, lib, ... }:


{
  environment = {
    variables = {
      EDITOR = "vim";
    };

    systemPackages = with pkgs; [
      bashCompletion
      gcc
      git                                # Git source control
      gnumake
      go
      go2nix
      godep
      python27
      python27Packages.pip
      python27Packages.virtualenv
      sqlite
      vimPlugins.YouCompleteMe
      vim_configurable
      which
    ];
  };

  # Enable docker contaner svc
  virtualisation.docker.enable = true;
}
