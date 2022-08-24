{ config, pkgs, ... }:
let
  gunicorn = "${pkgs.python38Packages.gunicorn}";
  python-with-packages = pkgs.python38.withPackages (pp: with pp; [
    flask
    opencv4
  ]);
in
{
  services.influxdb.enable = true;
  networking.firewall.allowedTCPPorts = [ 5555 ];
  systemd.services.cam-view  = {
    path = with pkgs; [
      python38Packages.gunicorn
      python38
      python-with-packages
    ];
    description = "Web app to get jpeg from security cam";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    environment = {
       PYTHONPATH = "${python-with-packages}/${python-with-packages.sitePackages}";
    };
    serviceConfig = {
      Type = "simple";
      User = "nginx";
      Group = "nginx";
      Restart = "always";
      WorkingDirectory = "/var/www/esp32-rstp-view/";
      ExecStart = "${gunicorn}/bin/gunicorn --bind 0.0.0.0:5555 wsgi:app";
    };
  };
}
