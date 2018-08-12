{ config, pkgs, ... }:
let
  domain = "home.net";
  base="192.168.2";
in
{
  services.dnsmasq = {
    enable = true;
    # OpenDNS
    servers = [ "208.67.222.222" "208.67.220.220" ];
    extraConfig = ''
      domain-needed
      bogus-priv

      # needed for dns lookups to work
      domain = ${domain}
      expand-hosts
      local=/${domain}/

      listen-address=127.0.0.1,${base}.58
      bind-interfaces
      dhcp-range=lan,${base}.12,${base}.250

      #set default gateway
      dhcp-option=lan,3,${base}.1

      #set DNS server
      dhcp-option=lan,6,${base}.58

      dhcp-boot=pxelinux.0
      enable-tftp
      tftp-root=/opt/tftpboot/

      # Static IPs
      dhcp-host=30:cd:a7:a3:c6:46,${base}.2
      dhcp-host=ac:9e:17:b8:d6:d2,${base}.53
      dhcp-host=b8:ac:6f:7d:f7:ed,${base}.58
      dhcp-host=00:90:a9:d9:83:2e,${base}.82,senddata
      dhcp-host=b8:27:eb:43:48:6c,${base}.107
      dhcp-host=00:1e:06:33:c1:d2,${base}.134
      dhcp-host=b8:27:eb:d2:c7:91,${base}.138
      dhcp-host=b8:ae:ed:eb:47:cd,${base}.158
      dhcp-host=80:c1:6e:71:9e:e0,${base}.222,proxmox-mgt
      dhcp-host=e4:11:5b:ce:e7:9c,${base}.221,proxmox

      # Unifi gear
      dhcp-host=80:2a:a8:93:cf:72,${base}.3
      dhcp-host=f0:9f:c2:19:4e:61,${base}.4
      dhcp-host=f0:9f:c2:26:8f:e8,${base}.141
      dhcp-host=f0:9f:c2:c4:5f:91,${base}.169

      # Hue Bridge
      dhcp-host=00:17:88:2f:96:76,${base}.47

      # Proxmox VMs/LXCs (use 6-12 for now)
      dhcp-host=9E:04:15:49:D1:C8,${base}.6,rhel75
    '';
  };

  # Need a static IP
  networking = {
    defaultGateway = "${base}.1";
    # TODO: update to ipv4 option
    interfaces.eno1.ip4 = [ { address = "${base}.58"; prefixLength = 24; } ];
    interfaces.eno1.useDHCP = false;

    firewall.allowedTCPPorts = [ 53 ];
    firewall.allowedUDPPorts = [ 53 67 ];

    # DNS hostnames for dnsmasq
    extraHosts = ''
      # For unifi gear to find the controller
      # Dines
      ${base}.58   unifi dinero-serv

      ${base}.82   senddata
      ${base}.107  retropie

      ${base}.221  proxmox
      ${base}.222  proxmox-mgt

      # VMs
      ${base}.6   rhel75

    '';
  };
}
