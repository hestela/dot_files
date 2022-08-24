{ config, pkgs, ... }:
let
  data = "-v /opt/heimdall:/config";
  image = "ghcr.io/linuxserver/heimdall";
  #image = "linuxserver/heimdall";
  other = "-e PUID=999 -e PGID=131 -e TZ=America/Los_Angeles -p 5050:80 -p 5060:443";
  name = "heimdall";
  opts = "${data} ${other} ${image}";
  group = "docker";
in

{
  networking.firewall.allowedTCPPorts = [ 5050 5060 ];
  systemd.services.heimdall = {
    path = with pkgs; [
      docker
    ];
    description = "heimdall dashboard via docker";
    wantedBy = [ "multi-user.target" ];
    after = [ "syslog.target" "network.target" ];
    serviceConfig = {
      Type = "simple";
      User = "heimdall";
      Group = "docker";
      Restart = "always";
      ExecStart = "${pkgs.docker}/bin/docker run --restart=always --name=${name} ${opts}";
      ExecStop = "${pkgs.docker}/bin/docker stop ${name}";
      ExecStopPost = "${pkgs.docker}/bin/docker rm -f ${name}";
      ExecReload = "${pkgs.docker}/bin/docker restart ${name}";
    };
  };
}
