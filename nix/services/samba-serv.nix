{ config, pkgs, ... }:
{
    networking.firewall.allowedTCPPorts = [ 445 139 ];
    networking.firewall.allowedUDPPorts = [ 137 138 ];

    services.samba = {
      enable = true;
      securityType = "user";
      extraConfig = ''
        workgroup = WORKGROUP
        server string = smbnix
        netbios name = smbnix
        security = user
        #use sendfile = yes
        max protocol = smb2
        guest account = nobody
        map to guest = bad user
        '';
        shares = {
          brogan = {
            path = "/share/brogan0";
            browseable = "yes";
            "read only" = "no";
            "guest ok" = "yes";
            "create mask" = "0644";
            "directory mask" = "0755";
            "force user" = "nginx";
            "force group" = "nginx";
          };
        help = {
          path = "/var/www/preseed";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "yes";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "nginx";
          "force group" = "nginx";
        };
      };
    };
}

