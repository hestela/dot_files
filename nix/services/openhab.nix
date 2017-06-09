{ config, pkgs, ... }:

{
  users.extraUsers.openhab = {
    isNormalUser = true;
    home = "/home/openhab";
    extraGroups = [ "openhab" ];
  };

  users.extraGroups.openhab = {
    name = "openhab";
  };

  # Default port is 8080
  systemd.services.openhab = {
    path = with pkgs; [
      jre
      bash
      gawk
    ];
    description = "The openHAB 2 Home Automation Bus Solution";
    wantedBy = [ "multi-user.target" ];
    after = [ "syslog.target" "network.target" ];
    environment.HOME = "/home/openhab";
    environment.USER = "openhab";
    environment.OPENHAB_HTTP_PORT = "7080";
    environment.OPENHAB_HTTPS_PORT = "7443";
    # TODO: fix manual unpack of zip to home
    serviceConfig = {
      Type = "simple";
      User = "openhab";
      Group = "openhab";
      WorkingDirectory = "/home/openhab";
      Restart = "always";
      ExecStart = "/home/openhab/start.sh server";
    };
  };
}
