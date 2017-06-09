{ config, pkgs, ... }:

let
  fauxmopkg = import ../pkgs/fauxmo.nix;
in
{
  networking.firewall.allowedTCPPorts = [ 52002 52003 52004 52005 ];
  systemd.services.fauxmo = {
    path = with pkgs; [
      python35
     (import ../pkgs/fauxmo.nix)
    ];
    description = "Create fake WeMo smart outlets for Amazon Echo to see";
    wantedBy = [ "multi-user.target" ];
    after = [ "syslog.target" "network.target" ];
    environment.USER = "root";
    serviceConfig = {
      Type = "simple";
      User = "root";
      Group = "root";
      Restart = "always";
      ExecStart = "${fauxmopkg}/bin/fauxmo -c /root/dot_files/nix/services/fauxmo-config.json";
    };
  };
}
