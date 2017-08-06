{ config, pkgs, ... }:

let
  radicaleDir = "/etc/radicale";
  radicalePkg = import ../pkgs/radicale.nix;
in
{
  environment.systemPackages = with pkgs;
  [
    perlPackages.AuthenHtpasswd
  ];

  users.extraUsers.radicale= {
    isNormalUser = false;
    home = "/etc/radicale/";
    createHome = true;
  };

  # radicale config file
  environment.etc =
  {
    "radicale/config" =
    {
      text =
      ''
        [server]
        # Bind all addresses
        hosts = 0.0.0.0:5232

        [auth]
        htpasswd_filename = ${radicaleDir}/.htpasswd
        htpasswd_encryption = htpasswd
        [storage]
        filesystem_folder = ${radicaleDir}/collections
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [ 5232 ];

  systemd.services.radicale = {
    path = with pkgs; [
      radicalePkg
      python35
      python35Packages.bcrypt
      python35Packages.passlib
    ];

    description = "A simple CalDAV (calendar) and CardDAV (contact) server";
    wantedBy = [ "multi-user.target" ];
    after = [ "syslog.target" "network.target" ];
    serviceConfig = {
      Type = "simple";
      User = "radicale";
      Restart = "always";
      ExecStart = "${radicalePkg}/bin/radicale";
      ReadWritePaths = "${radicaleDir}/collections";
    };
  };
}
