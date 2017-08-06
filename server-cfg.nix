{ config, pkgs, ... }:

# Symlink this file to /etc/nixos/configuration.nix
{
  imports =
    [
      /etc/nixos/hardware-configuration.nix
      /root/dot_files/nix/common.nix
      /root/dot_files/nix/development.nix
      /root/dot_files/nix/services/nginx.nix
      /root/dot_files/nix/machines/server.nix
    ];
}
