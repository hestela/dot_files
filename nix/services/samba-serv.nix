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
        www = {
          path = "/var/www/preseed";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "yes";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "nginx";
          "force group" = "nginx";
        };
        scans = {
          path = "/share/zfs/scans";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "yes";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "nginx";
          "force group" = "nginx";
        };
        random = {
          path = "/share/zfs/random";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "valid users" = "henry";
        };
      };
    };
}

