{ config, pkgs, ... }:

{
  # Use network manager for networking
  networking.networkmanager.enable = true;
  networking.enableIPv6 = false;
  networking.nameservers = [ "8.8.8.8" ];

  # DHCP wasn't working for some reason
  networking.defaultGateway = "192.168.1.1";
  networking.interfaces.eno1.ip4 = [ { address= "192.168.1.28"; prefixLength = 24;} ];
  networking.interfaces.eno1.useDHCP = false;
}
