{ config, pkgs, lib, ... }:


{
  # FIXME: not a very useful file
  imports = [ ./pkgs/rust.nix ];
  environment = {
    variables = {
      EDITOR = "vim";
    };

    systemPackages = with pkgs; [
      bashCompletion
      cargoLatest
      gcc
      git                                # Git source control
      gnumake
      go
      go2nix
      godep
      python27
      python27Packages.pip
      python27Packages.virtualenv
      rustcLatest
      sqlite
      vimPlugins.YouCompleteMe
      vim_configurable
      which
    ];
  };

  # Enable docker contaner svc
  virtualisation.docker.enable = true;
}
