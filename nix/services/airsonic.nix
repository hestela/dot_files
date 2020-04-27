{ config, pkgs, ... }:
let
  image = "airsonic";
  data = "-v /opt/airsonic/data:/airsonic/data";
  music = "-v /opt/music:/airsonic/music";
  playlists = "-v /opt/airsonic/playlists:/airsonic/playlists";
  podcats = "-v /opt/airsonic/podcasts:/airsonic/podcasts";
  opts = "${data} ${music} ${playlists} ${podcats} -p 4040:4040 airsonic/airsonic";
in

{
  networking.firewall.allowedTCPPorts = [ 4040 ];
  systemd.services.airsonic = {
    path = with pkgs; [
      docker
    ];
    description = "airsonic server via docker";
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
