{ config, pkgs, ... }:
{
  boot = {
    kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
    };
  };
  networking = {
    firewall = {
      enable = true;
      extraCommands = ''
        iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j SNAT --to 192.168.0.111
      '';
      extraStopCommands = ''
        iptables -t nat -D POSTROUTING -s 10.8.0.0/24 -j SNAT --to 192.168.0.111
      '';
      allowedUDPPorts = [ 8080 ]; # openvpn
      trustedInterfaces = [ "tun1" ];
    };
  };
  services = {
    openvpn = {
      servers = {
        no-lan = {
          config = ''
            dev tun1
            server 10.8.0.0 255.255.255.0
            port 8080
            comp-lzo
            ca /root/easy-rsa/easyrsa3/pki/ca.crt
            cert /root/easy-rsa/easyrsa3/pki/issued/no-pass.crt
            key /root/easy-rsa/easyrsa3/pki/private/no-pass.key
            dh /root/easy-rsa/easyrsa3/pki/dh.pem
            tls-auth /root/ta.key 0
            tls-server
            push "redirect-gateway local def1 bypass-dhcp"
            push "dhcp-option DNS 8.8.8.8"
            push "route 192.168.0.0 255.255.255.0"
            push "route 10.8.0.0 255.255.255.0"
            client-to-client
          '';
        };
      };
    };
  };
}
