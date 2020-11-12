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
      python27
      python27Packages.pip
      python27Packages.virtualenv
      sqlite
      vim_configurable
      which
    ];
  };

  # Enable docker contaner svc
  virtualisation.docker.enable = true;
}
