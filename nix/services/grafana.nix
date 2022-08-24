{ config, pkgs, ... }:
{
  services.grafana = {
    enable   = true;
    port     = 3000;
    domain   = "easycashmoney.org";
    rootUrl = "https://easycashmoney.org/";
    protocol = "http";
    dataDir  = "/var/lib/grafana";
    addr = "";
  };

  systemd.services.grafana = {
    # wait until all network interfaces initialize before starting Grafana
    after = [ "network-interfaces.target" ];
    wants = [ "network-interfaces.target" ];
  };
}
