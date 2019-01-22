{ config, pkgs, ... }:
let
  dot_files=/root/dot_files/nix;
in
{
  systemd.services.xbox-init = {
    path = with pkgs; [
      xboxdrv
      bash
      usbutils
    ];
    description = "xbox config for srteam";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "simple";
      User = "root";
      Group = "root";
      Restart = "no";
      ExecStartPre = "${pkgs.bash}/bin/bash ${dot_files}/services/rmmod.sh xpad";
      ExecStart = "${pkgs.bash}/bin/bash ${dot_files}/services/xbox-script.sh";
    };
  };
}
