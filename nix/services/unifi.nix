{ config, pkgs, ... }:
let
  image = "registry.easycashmoney.org/hrestela/unifi-docker/unifi-docker";
in
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
      ExecStart = "${pkgs.docker}/bin/docker run --restart=always --name=unifi --net=host -v /var/local/unifi/data:/usr/lib/unifi/data ${image}";
      ExecStartPre = "${pkgs.bash}/bin/bash -c '${pkgs.docker}/bin/docker pull ${image}' || true";
      ExecStop = "${pkgs.docker}/bin/docker stop unifi";
      ExecStopPost = "${pkgs.docker}/bin/docker rm -f unifi";
      ExecReload = "${pkgs.docker}/bin/docker restart unifi";
    };
  };
}
