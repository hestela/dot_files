{ config, pkgs, ... }:
let
  grafanaPort = 3000;
  influxApiPort = 8086;
  ipAddress = "127.0.0.1";
  mkGrafanaInfluxSource = db: {
    name = "My Influx-${db} DB";
    type = "influxdb";
    database = db;
    editable = false; # Force editing in this file.
    access = "proxy";
    # user = "grafana"; # fill in Grafana InfluxDB user, if enabled
    # password = "grafana";
    url = ("http://${ipAddress}:${toString influxApiPort}");
  };
in
{
  networking.firewall.allowedUDPPorts = [ 8086 ];
  services.influxdb.enable = true;
  services.grafana = {
    enable   = true;
    port     = 3000;
    domain   = "gps.easycashmoney.org";
    rootUrl = "https://gps.easycashmoney.org/";
    protocol = "http";
    dataDir  = "/var/lib/grafana";
    addr = "";
  };

  systemd.services.grafana = {
    # wait until all network interfaces initialize before starting Grafana
    after = [ "network-interfaces.target" ];
    wants = [ "network-interfaces.target" ];
  };
  services.grafana.provision = {
    enable = true;
    datasources = map mkGrafanaInfluxSource
      ["gps"];
  };
}
