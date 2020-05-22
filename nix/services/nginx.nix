{ config, pkgs, ... }:
let
  url = "easycashmoney.org";
in
{
  # TEMP
  networking.firewall.allowedTCPPorts = [ 5500 ];
  # SQL
  services.mysql.enable = true;
  services.mysql.package = pkgs.mysql;
  services.mysql.dataDir = "/var/db/mysql";

  security.acme = {
    email = "admin@easycashmoney.org";
    acceptTerms = true;
    certs = {
      "${url}" = {
        user = "nginx";
        group = "git";
        allowKeysForGroup = true;
        #webroot = "/var/www/challenges/";
        # Test LE server
        #server = "https://acme-staging-v02.api.letsencrypt.org/directory";
        extraDomains = {
          "game.${url}" = null;
          "unifi.${url}" = null;
          "gitlab.${url}" = null;
          "music.${url}" = null;
          "meet.${url}" = null;
          "gps.${url}" = null;
        };
      };
    };
  };

  services.nginx = {
    enable = true;
    logError = "/var/log/nginx-error.log";
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # Reverse proxies
    virtualHosts."game.easycashmoney.org" = {
      forceSSL = true;
      useACMEHost = "${url}";
      locations."/".proxyPass = "http://localhost:4200";
    };
    virtualHosts."meet.easycashmoney.org" = {
      forceSSL = true;
      useACMEHost = "${url}";
      locations."/".proxyPass = "http://localhost:999";
    };
    virtualHosts."gps.easycashmoney.org" = {
      forceSSL = true;
      useACMEHost = "${url}";
      locations."/".proxyPass = "http://localhost:5500";
    };

    virtualHosts."unifi.easycashmoney.org" = {
      forceSSL = true;
      useACMEHost = "${url}";
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
      default = true;
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
      useACMEHost = "${url}";
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
      extraConfig = ''
          autoindex on;
          location / {
            allow 192.168.2.0/24;
            deny all;
          }
      '';
    };
  };
}
