{ config, pkgs, ... }:
let
  data = "-v /opt/airsonic/data-adv:/var/airsonic/";
  music = "-v /opt/music:/var/music/henry";
  brogan_music = "-v /share/brogan0/airsonic-music:/var/music/brogan";
  playlists = "-v /opt/airsonic/playlists:/var/playlists";
  podcats = "-v /opt/airsonic/podcasts:/var/podcast";
  image = "airsonicadvanced/airsonic-advanced:latest";

  name = "airsonic";
  opts = "${data} ${music} ${brogan_music} ${playlists} ${podcats} -p 4040:4040 ${image}";
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
      ExecStart = "${pkgs.docker}/bin/docker run --restart=always --name=${name} ${opts}";
      ExecStop = "${pkgs.docker}/bin/docker stop ${name}";
      ExecStopPost = "${pkgs.docker}/bin/docker rm -f ${name}";
      ExecReload = "${pkgs.docker}/bin/docker restart ${name}";
    };
  };
}
