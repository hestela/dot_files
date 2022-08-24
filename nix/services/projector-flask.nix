{ config, pkgs, ... }:
let
  gunicorn = "${pkgs.python39Packages.gunicorn}";
  python-with-packages = pkgs.python39.withPackages (pp: with pp; [
    flask
    requests
  ]);
in
{
  systemd.services.projector-app  = {
    path = with pkgs; [
      python39Packages.gunicorn
      python39Packages.requests
      python39
      python-with-packages
    ];
    description = "Web app to route projector commands for openhab";
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
      WorkingDirectory = "/var/www/projector";
      ExecStart = "${gunicorn}/bin/gunicorn --bind 0.0.0.0:6600 wsgi:app";
    };
  };
}
