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
    nameservers = [ "8.8.8.8" ];

    firewall.allowedTCPPorts = [ 53 ];
    firewall.allowedUDPPorts = [ 53 67 ];

    # DNS hostnames for dnsmasq
    extraHosts = ''
      # For unifi gear to find the controller
      ${base}.58   unifi bones
      ${base}.124  bones-mgt

      ${base}.82   senddata
      ${base}.107  retropie
      ${base}.142  octopi

      ${base}.26   proxmox-mgt
      ${base}.221  proxmox

      # VMs
      ${base}.7   ubuntu1804
      ${base}.8   rhel75
      ${base}.9   slurm-head

      # Frenas server
      ${base}.223   idrac-truenas
      ${base}.224   truenas
    '';
  };
}
