{ config, pkgs, ... }:
{
    environment = {
    systemPackages = let pkgsUnstable = import
    (
      fetchTarball https://github.com/NixOS/nixpkgs/archive/master.tar.gz
    )
    { };
    in
    with pkgs; [
      openssl
      letsencrypt
      php
      pkgsUnstable.certbot
    ];
  };

  # SQL
  services.mysql.enable = true;
  services.mysql.package = pkgs.mysql;
  services.mysql.dataDir = "/var/db/mysql";

  security.acme.email = "admin@easycashmoney.org";
  security.acme.acceptTerms = true;
  services.nginx = {
    enable = true;

    # Reverse proxies
    virtualHosts."ci.easycashmoney.org" = {
      forceSSL = true;
      enableACME = true;
      locations."/".proxyPass = "http://localhost:8000";
    };
    virtualHosts."git.easycashmoney.org" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:1111";
    };
    virtualHosts."game.easycashmoney.org" = {
      forceSSL = true;
      enableACME = true;
      locations."/".proxyPass = "http://localhost:4200";
    };
    virtualHosts."meet.easycashmoney.org" = {
      forceSSL = true;
      enableACME = true;
      locations."/".proxyPass = "http://localhost:999";
    };

    virtualHosts."unifi.easycashmoney.org" = {
      forceSSL = true;
      enableACME = true;
      sslTrustedCertificate = "/etc/ssl/certs/unifi.pem";

      # Custom proxy pass for unifi https
      locations."/" = {
        extraConfig = ''
            proxy_pass https://localhost:8443;
            proxy_redirect https://localhost:8443 https://unifi.easycashmoney.org;
            proxy_set_header Host unifi.easycashmoney.org;
          '';
      };
    };

    # Basic folder serving
    virtualHosts."easycashmoney.org" = {
      forceSSL = true;
      enableACME = true;
      root = "/var/www/files/";
      basicAuthFile = "/var/www/brogan-htpasswd";
      extraConfig = ''
          autoindex on;
          location \ {
            deny all;
            allow 192.168.2.0/24;
          }
      '';
    };
    virtualHosts."music.easycashmoney.org" = {
      forceSSL = true;
      enableACME = true;
      basicAuthFile = "/var/www/brogan-htpasswd";
      root = "/share/brogan0/";
      extraConfig = ''
          autoindex on;
          location \ {
            deny all;
            allow 192.168.2.0/24;
          }
      '';
    };
    virtualHosts."bones.corp.easycashmoney.org" = {
      root = "/var/www/preseed";
    };
  };
}
