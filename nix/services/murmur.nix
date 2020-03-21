{ config, pkgs, ... }:
let
  base = "/var/local/murmur";
  base_d = "/opt/murmur";
  image = "goofball222/murmur";

  mount_cert = "-v ${base}/cert:${base_d}/cert";
  mount_conf = "-v ${base}/config:${base_d}/config";
  mount_data = "-v ${base}/data:${base_d}/data";
  mount_log = "-v ${base}/log:${base_d}/log";
  mount = "${mount_cert} ${mount_conf} ${mount_data} ${mount_log}";

  port = "-p 64738:64738/udp -p 64738:64738";
  opts = "${mount} ${port} ${image}";
in

{
  networking.firewall.allowedTCPPorts = [ 64738 ];
  networking.firewall.allowedUDPPorts = [ 64738 ];
  systemd.services.murmurDocker = {
    path = with pkgs; [
      docker
    ];
    description = "Murmur server via docker";
    wantedBy = [ "multi-user.target" ];
    after = [ "syslog.target" "network.target" ];
    environment.USER = "root";
    serviceConfig = {
      Type = "simple";
      User = "root";
      Group = "root";
      Restart = "always";
      ExecStart = "${pkgs.docker}/bin/docker run --restart=always --name=murmur ${opts}";
      ExecStop = "${pkgs.docker}/bin/docker stop murmur";
      ExecStopPost = "${pkgs.docker}/bin/docker rm -f murmur";
      ExecReload = "${pkgs.docker}/bin/docker restart murmur";
    };
  };
}
