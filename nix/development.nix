{ config, pkgs, lib, ... }:


{
  environment = {
    variables = {
      EDITOR = "vim";
    };

    systemPackages = with pkgs; [
      bash-completion
      gcc
      git                                # Git source control
      gnumake
      go
      sqlite
      vim_configurable
      which
      file
    ];
  };

  # Enable docker contaner svc
  virtualisation.docker.enable = true;
}
