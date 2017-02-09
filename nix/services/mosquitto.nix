{ config, pkgs, ... }:

{
  users.extraUsers.mosquitto = {
    isNormalUser = true;
    home = "/home/mosquitto";
    extraGroups = [ "mosquitto" ];
  };

  users.extraGroups.mosquitto = {
    name = "mosquitto";
  };

  systemd.services.mosquitto = {
    path = with pkgs; [
      mosquitto
    ];
    description = "mosquitto mqtt broker";
    wantedBy = [ "multi-user.target" ];
    after = [ "syslog.target" "network.target" ];
    environment.HOME = "/home/mosquitto";
    environment.USER = "mosquitto";
    preStart = ''
      mkdir -p /home/mosquitto/data
      echo "
        pid_file /var/run/mosquitto.pid

        persistence true
        persistence_location /home/mosquitto/data

        user mosquitto

        port 1883
        listener 9001
        protocol websockets

        log_dest file /home/mosquitto/mosquitto.log
        log_dest stdout
      " > /home/mosquitto/mosquitto.conf
    '';
    serviceConfig = {
      Type = "simple";
      User = "mosquitto";
      Group = "mosquitto";
      GuessMainPID = "yes";
      WorkingDirectory = "/home/mosquitto";
      Restart = "always";
      ExecStart = "${pkgs.mosquitto}/bin/mosquitto -c /home/mosquitto/mosquitto.conf";
    };
  };
}
