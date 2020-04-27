{ config, pkgs, ... }:
let
  compose = "${pkgs.docker-compose}/bin/docker-compose";
in

{
  # 999/998 are custom http/s ports
  networking.firewall.allowedTCPPorts = [ 4443 999 998 ];
  networking.firewall.allowedUDPPorts = [ 10000 ];
  systemd.services.jitsiDocker = {
    path = with pkgs; [
      docker
      docker-compose
    ];
    description = "jitsi meet server via docker";
    wantedBy = [ "multi-user.target" ];
    after = [ "syslog.target" "network.target" ];
    environment.USER = "root";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      User = "root";
      Group = "root";
      WorkingDirectory = "/root/jitsi-meet";
      ExecStart = "${compose} -f docker-compose.yml up -d";
      ExecStop = "${compose} -f docker-compose.yml down";
    };
  };
}
