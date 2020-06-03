{ config, pkgs, ... }:
let
  domain = "corp.easycashmoney.org";
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

      # Block some ads
      addn-hosts=/etc/dns-ads.txt
      conf-file=/etc/dns-conf.txt

      # needed for dns lookups to work
      domain = ${domain}
      expand-hosts
      local=/${domain}/

      listen-address=127.0.0.1,${base}.58
      bind-interfaces
      dhcp-range=lan,${base}.12,${base}.250,24h

      #set default gateway
      dhcp-option=lan,3,${base}.1

      #set DNS server
      dhcp-option=lan,6,${base}.58,8.8.8.8

      dhcp-boot=pxelinux.0
      enable-tftp
      tftp-root=/opt/tftpboot/

      # Static IPs
      dhcp-host=30:cd:a7:a3:c6:46,${base}.2
      dhcp-host=00:26:B9:5F:F8:0B,${base}.11
      dhcp-host=ac:9e:17:b8:d6:d2,${base}.53
      dhcp-host=00:e0:81:cc:a1:45,${base}.58,bones
      dhcp-host=00:e0:81:cc:a0:a3,${base}.124,bones-mgt
      dhcp-host=00:90:a9:d9:83:2e,${base}.82,senddata
      dhcp-host=b8:27:eb:43:48:6c,${base}.107
      dhcp-host=01:94:c6:91:1d:1c:16,${base}.130,Henrys-iMac
      dhcp-host=00:1e:06:33:c1:d2,${base}.134
      dhcp-host=b8:27:eb:d2:c7:91,${base}.138
      dhcp-host=b8:27:eb:df:01:3c,${base}.142,octopi
      dhcp-host=b8:ae:ed:eb:47:cd,${base}.158
      dhcp-host=e4:11:5b:ce:e7:9c,${base}.26,proxmox-mgt
      dhcp-host=80:c1:6e:71:9e:e0,${base}.221,proxmox
      dhcp-host=b8:ac:6f:7d:f7:ed,${base}.193,centos
      dhcp-host=00:26:b9:5f:f8:03,${base}.194,steamed-hams
      dhcp-host=98:09:cf:5b:33:40,${base}.91,OnePlusCashMoney

      #dhcp-host=00:1c:2e:bb:24:40,${base}.197,procurve-bedroom

      # Unifi gear
      dhcp-host=80:2a:a8:93:cf:72,${base}.3
      dhcp-host=f0:9f:c2:19:4e:61,${base}.4
      dhcp-host=f0:9f:c2:26:8f:e8,${base}.141
      dhcp-host=f0:9f:c2:c4:5f:91,${base}.169

      # Hue Bridge
      dhcp-host=00:17:88:2f:96:76,${base}.47

      # Proxmox VMs/LXCs (use 6-12 for now)
      dhcp-host=62:82:0E:22:08:D0,${base}.7,ubuntu1804
      dhcp-host=1A:BF:F1:B8:6A:4C,${base}.8,rhel75
      dhcp-host=06:C4:EC:57:CD:07,${base}.9,slurm-head
    '';
  };

  # Need a static IP
  networking = {
    defaultGateway = "${base}.1";
    interfaces.eno1.ipv4.addresses = [ { address = "${base}.58"; prefixLength = 24; } ];
    interfaces.eno1.useDHCP = false;

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
      ${base}.194  steamed-hams
      ${base}.11   steamed-hams-mgt

      ${base}.130 Henrys-iMac 01:94:c6:91:1d:1c:16

      # VMs
      ${base}.7   ubuntu1804
      ${base}.8   rhel75
      ${base}.9   slurm-head
    '';
  };
}
