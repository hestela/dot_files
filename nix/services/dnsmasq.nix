{ config, pkgs, ... }:
let
  domain = "corp.easycashmoney.org";
  base="192.168.2";
in
{
  # Need a static IP
  networking = {
    defaultGateway = "${base}.1";
    interfaces.ens18.ipv4.addresses = [ { address = "${base}.58"; prefixLength = 24; } ];
    interfaces.ens18.useDHCP = false;
    nameservers = [ "192.168.2.214" "8.8.8.8" ];

    firewall.allowedTCPPorts = [ 53 ];
    firewall.allowedUDPPorts = [ 53 67 ];
  };
}
