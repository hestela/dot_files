{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 8080 8880 8843 8443 ];
  networking.firewall.allowedUDPPorts = [ 3478 10001 ];
  systemd.services.unifiDocker = {
    path = with pkgs; [
      docker
    ];
    description = "Unifi controller service via docker";
    wantedBy = [ "multi-user.target" ];
    after = [ "syslog.target" "network.target" ];
    environment.USER = "root";
    serviceConfig = {
      Type = "simple";
      User = "root";
      Group = "root";
      Restart = "always";
      ExecStart = "${pkgs.docker}/bin/docker run --restart=always --name=unifi --net=host -v /var/local/unifi/data:/usr/lib/unifi/data unifi-controller-local";
#      ExecStartPre = "${pkgs.docker}/bin/docker pull godmodelabs/unifi-controller";
      ExecStop = "${pkgs.docker}/bin/docker stop unifi";
      ExecStopPost = "${pkgs.docker}/bin/docker rm -f unifi";
      ExecReload = "${pkgs.docker}/bin/docker restart unifi";
    };
  };
}
