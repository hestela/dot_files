{ config, pkgs, ... }:
let
  dockerImage = "openhab/openhab:2.4.0-amd64-debian";
in
{
  users.extraUsers.openhab = {
    isNormalUser = true;
    home = "/home/openhab";
    extraGroups = [ "openhab" "docker" ];
  };

  users.extraGroups.openhab = {
    name = "openhab";
  };

  networking.firewall.allowedTCPPorts = [ 7080 7443 ];

  systemd.services.openhab = {
    path = with pkgs; [
      jre
      bash
      gawk
      procps
      ipmitool
      docker
    ];

    description = "The openHAB 2 Home Automation Bus Solution";
    wantedBy = [ "multi-user.target" ];
    after = [ "docker.service" ];
    environment.USER = "openhab";

    serviceConfig = {
      Type = "simple";
      User = "openhab";
      Group = "openhab";
      WorkingDirectory = "/home/openhab";
      Restart = "always";
      ExecStartPre = "${pkgs.docker}/bin/docker pull ${dockerImage}";
      ExecStart = "${pkgs.docker}/bin/docker run --name openhab --net=host -v /etc/localtime:/etc/localtime:ro  -v /etc/timezone:/etc/timezone:ro -v /home/openhab/conf:/openhab/conf -v /home/openhab/userdata:/openhab/userdata -v /home/openhab/addons:/openhab/addons -e USER_ID=1002 -e GROUP_ID=498 -e OPENHAB_HTTP_PORT=7080 -e OPENHAB_HTTPS_PORT=7443 --restart=always -v /dev/ipmi0:/dev/ipmi0 ${dockerImage}";
      ExecStop = "${pkgs.docker}/bin/docker stop openhab";
      ExecStopPost = "${pkgs.docker}/bin/docker rm -f openhab";
      ExecReload = "${pkgs.docker}/bin/docker restart openhab";
    };
  };
}
