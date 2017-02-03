{ config, pkgs, ... }:

# Symlink this file to /etc/nixos/configuration.nix
{
  imports =
    [
      /etc/nixos/hardware-configuration.nix
      /root/dot_files/nix/common.nix
      /root/dot_files/nix/desktop.nix
      /root/dot_files/nix/development.nix
      /root/dot_files/nix/openssh.nix
      # Intentionally left out of git
      /root/dot_files/nix/work.nix
    ];
}
