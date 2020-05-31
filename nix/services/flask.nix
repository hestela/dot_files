{ config, pkgs, ... }:
let
  gunicorn = "${pkgs.python38Packages.gunicorn}";
  python-with-packages = pkgs.python38.withPackages (pp: with pp; [
    influxdb
    flask
    gpxpy
  ]);
in
{
  services.influxdb.enable = true;
  networking.firewall.allowedTCPPorts = [ 5500 ];
  networking.firewall.allowedUDPPorts = [ 8086 ];
  systemd.services.gps-app  = {
    path = with pkgs; [
      python38
      python38Packages.gunicorn
      git
      openssh
      python-with-packages
    ];
    description = "Web app to accept gps coordinates";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    environment = {
       GIT_SSH_COMMAND = "ssh -oPort=42063 -i /var/www/key/nginx -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no";
       PYTHONPATH = "${python-with-packages}/${python-with-packages.sitePackages}";
    };
    serviceConfig = {
      Type = "simple";
      User = "nginx";
      Group = "nginx";
      Restart = "always";
      WorkingDirectory = "/var/www/esp32-gps/flask";
      ExecStartPre = "${pkgs.git}/bin/git pull origin master";
      ExecStart = "${gunicorn}/bin/gunicorn --bind 0.0.0.0:5500 wsgi:app";
    };
  };
}
