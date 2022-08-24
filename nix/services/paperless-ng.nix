{ config, pkgs, ... }:
let
  compose = "${pkgs.docker-compose}/bin/docker-compose";
in

{
  systemd.services.paperless-docker = {
    path = with pkgs; [
      docker
      docker-compose
    ];
    description = "paperless-ng via docker";
    wantedBy = [ "multi-user.target" ];
    after = [ "syslog.target" "network.target" ];
    environment.USER = "paperless";
    serviceConfig = {
      Type = "simple";
      User = "paperless";
      Group = "docker";
      WorkingDirectory = "/share/zfs/paperless-ng";
      ExecStart = "${compose} -f docker-compose.yml up -d";
      ExecStop = "${compose} -f docker-compose.yml down";
    };
  };
}
