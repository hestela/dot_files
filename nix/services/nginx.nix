{ config, pkgs, ... }:
let
  cert = "/etc/letsencrypt/live/gitlab.easycashmoney.org/fullchain.pem";
  key = "/etc/letsencrypt/live/gitlab.easycashmoney.org/privkey.pem";
  url = "easycashmoney.org";
  index_files_conf = ''
    autoindex on;
  '';
in
{
  # SQL
  services.mysql.enable = true;
  services.mysql.package = pkgs.mysql;
  services.mysql.dataDir = "/var/db/mysql";

  # RTMP
  networking.firewall.allowedTCPPorts = [ 1935 4344 5050 ];

  # ACME renewal hack
  # the inbox acme renewal is a hot mess when it comes to multiple subdomains
  # I am manually creating and renewing my certs since it is more reliable
  services.cron = {
    enable = true;
    systemCronJobs = [
      "0 0 0 ? * SUN *  root certbot renew --standalone --pre-hook \"systemctl stop nginx\" --post-hook \"systemctl start nginx\""
    ];
  };

  services.nginx = {
    package = (pkgs.nginx.override { modules = [ pkgs.nginxModules.rtmp ]; });
    enable = true;
    #logError = "/var/log/nginx-error.log";
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # Reverse proxies
    virtualHosts."game.easycashmoney.org" = {
      forceSSL = true;
      sslCertificate = "${cert}";
      sslCertificateKey = "${key}";
      locations."/".proxyPass = "http://localhost:4200";
    };
    virtualHosts."meet.easycashmoney.org" = {
      forceSSL = true;
      sslCertificate = "${cert}";
      sslCertificateKey = "${key}";
      locations."/".proxyPass = "http://localhost:999";
    };
    virtualHosts."gps.easycashmoney.org" = {
      forceSSL = true;
      sslCertificate = "${cert}";
      sslCertificateKey = "${key}";
      basicAuthFile = "/var/www/gps-htpasswd";
      locations."/" = {
        proxyPass = "http://localhost:5500";
      };
    };

    virtualHosts."music.broganohara.com" = {
      forceSSL = true;
      sslCertificate = "${cert}";
      sslCertificateKey = "${key}";
      locations."/".proxyPass = "http://localhost:4040";
    };

    virtualHosts."unifi.easycashmoney.org" = {
      forceSSL = true;
      sslCertificate = "${cert}";
      sslCertificateKey = "${key}";
      sslTrustedCertificate = "/var/keys/unifi.pem";

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
      sslCertificate = "${cert}";
      sslCertificateKey = "${key}";
      root = "/var/www/files/";
      basicAuthFile = "/var/www/brogan-htpasswd";
      extraConfig = "${index_files_conf}";
    };
    virtualHosts."music.easycashmoney.org" = {
      forceSSL = true;
      sslCertificate = "${cert}";
      sslCertificateKey = "${key}";
      basicAuthFile = "/var/www/brogan-htpasswd";
      root = "/share/brogan0/";
      extraConfig = "${index_files_conf}";
    };

    virtualHosts."broganohara.com" = {
      forceSSL = true;
      sslCertificate = "${cert}";
      sslCertificateKey = "${key}";
      locations."/" = {
        extraConfig = ''
          auth_basic secured;
          auth_basic_user_file /var/www/brogan-htpasswd;
          autoindex on;
          root /share/brogan0/;
        '';
      };

      locations."/Band-Practice-Recordings/" = {
        extraConfig = ''
          auth_basic secured;
          auth_basic_user_file /var/www/public-htpasswd;
          autoindex on;
          root /share/brogan0/;
        '';
      };
    };

    virtualHosts."bones.corp.easycashmoney.org" = {
      root = "/var/www/preseed";
      extraConfig = "${index_files_conf}";
    };
    virtualHosts."localhost" = {
      listen = [{ addr = "0.0.0.0"; port = 4344; }];
      locations."/auth" = {
        extraConfig = ''
          if ( $arg_psk = '${builtins.readFile /var/keys/rtmp}' ) {
            return 201;
          }
          return 404;
        '';
      };
    };

    # rtmp test
    appendConfig = ''
      rtmp {
        server {
                listen 1935;
                chunk_size 4096;
                ping 30s;
                notify_method get;

                allow play 192.168.2.0/24;
                deny play all;

                application live {
                        live on;
                        record off;
                        on_publish http://localhost:4344/auth;
                }
                application local {
                        live on;
                        record off;
                }
        }
      }
    '';

  };
}
