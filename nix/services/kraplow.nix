{ config, pkgs, ... }:
let
  image = "tomcat-kraplow";
  opts = "-p 4200:8080 ${image}";
in

{
  networking.firewall.allowedTCPPorts = [ 4200 ];
  systemd.services.kraplow = {
    path = with pkgs; [
      docker
    ];
    description = "kraplow server via docker";
    wantedBy = [ "multi-user.target" ];
    after = [ "syslog.target" "network.target" ];
    environment.USER = "root";
    serviceConfig = {
      Type = "simple";
      User = "root";
      Group = "root";
      Restart = "always";
      ExecStart = "${pkgs.docker}/bin/docker run --restart=always --name=${image} ${opts}";
      ExecStop = "${pkgs.docker}/bin/docker stop ${image}";
      ExecStopPost = "${pkgs.docker}/bin/docker rm -f ${image}";
      ExecReload = "${pkgs.docker}/bin/docker restart ${image}";
    };
  };
}
