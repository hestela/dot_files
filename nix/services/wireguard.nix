{ config, pkgs, ... }:
let
  port = 51820;
in
{
  boot = {
    kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
    };
  };
  networking = {
    nat = {
      enable = true;
      externalInterface = "enp4s0";
      internalInterfaces = [ "wg0" ];
    };

    firewall = {
      allowedUDPPorts = [ port ]; # should be open
      #iptables -t nat -A POSTROUTING -s 10.10.0.0/24 -o enp4s0 -j MASQUERADE
      extraCommands = ''
        iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o enp4s0 -j MASQUERADE
      '';
    };

    wireguard.interfaces = {
      wg0 = {
        ips = [ "10.10.0.1/24" ];
        listenPort = port;

        privateKeyFile = "/root/wireguard-keys/private";

        peers = [
          {
            publicKey = "E6KhvVcsQHWwkDjYCxvy5o0R9q60spJlshSI8+D6IgA=";
            allowedIPs = [ "0.0.0.0/0" ];
          }
        ];
      };
    };

  };
}
