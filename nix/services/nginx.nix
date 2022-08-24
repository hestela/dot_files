{ config, pkgs, ... }:
let
  cert = "/etc/letsencrypt/live/gitlab.easycashmoney.org-0001/fullchain.pem";
  key = "/etc/letsencrypt/live/gitlab.easycashmoney.org-0001/privkey.pem";
  url = "easycashmoney.org";
  index_files_conf = ''
    autoindex on;
  '';

  serve_files = ''
    autoindex on;
    location ~* \.cia$ {
      add_header Content-disposition "attachment; filename=$1";
    }
  '';
in
{
  # SQL
  services.mysql.enable = true;
  services.mysql.package = pkgs.mysql;
  services.mysql.dataDir = "/var/db/mysql";

  # RTMP
  networking.firewall.allowedTCPPorts = [ 1935 4344 5050 ];
  networking.firewall.allowedUDPPorts = [ 1935 ];

  # ACME renewal hack
  # the inbox acme renewal is a hot mess when it comes to multiple subdomains
  # I am manually creating and renewing my certs since it is more reliable
  services.cron = {
    enable = true;
    systemCronJobs = [
      "0 0 0 ? * SUN *  root certbot renew --standalone --pre-hook \"systemctl stop nginx\" --post-hook \"chown -R nginx:nginx /etc/letsencrypt/* && systemctl start nginx\""
    ];
    # "0 2 26 * * root systemctl restart unifiDocker"
  };

  services.nginx = {
    package = (pkgs.nginx.override { modules = [ pkgs.nginxModules.rtmp ]; });
    enable = true;
    #logError = "/var/log/nginx-error.log";
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # Remote proxy
    virtualHosts."gitlab.easycashmoney.org" = {
      forceSSL = true;
      sslCertificate = "${cert}";
      sslCertificateKey = "${key}";
      locations."/".proxyPass = "http://gitlab.corp.easycashmoney.org";
    };
    virtualHosts."registry.easycashmoney.org" = {
      forceSSL = true;
      sslCertificate = "${cert}";
      sslCertificateKey = "${key}";
      locations."/".proxyPass = "http://gitlab.corp.easycashmoney.org:5005";
    };
    # For remote docker registry
    clientMaxBodySize = "0";

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

    #virtualHosts."music.broganohara.com" = {
    #  forceSSL = true;
    #  sslCertificate = "${cert}";
    #  sslCertificateKey = "${key}";
    #  locations."/".proxyPass = "http://localhost:4040";
    #};

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


    # Grafana
    virtualHosts."easycashmoney.org" = {
      default = true;
      forceSSL = true;
      sslCertificate = "${cert}";
      sslCertificateKey = "${key}";
      locations."/".proxyPass = "http://localhost:3000";
    };

    #virtualHosts."music.easycashmoney.org" = {
    #  forceSSL = true;
    #  sslCertificate = "${cert}";
    #  sslCertificateKey = "${key}";
    #  basicAuthFile = "/var/www/brogan-htpasswd";
    #  root = "/share/brogan0/";
    #  extraConfig = "${index_files_conf}";
    #};

    virtualHosts."paperless.easycashmoney.org" = {
      forceSSL = true;
      sslCertificate = "${cert}";
      sslCertificateKey = "${key}";
      locations."/".proxyPass = "http://paperless.corp.easycashmoney.org:8000";
    };

    #virtualHosts."broganohara.com" = {
    #  forceSSL = true;
    #  sslCertificate = "${cert}";
    #  sslCertificateKey = "${key}";
    #  locations."/" = {
    #    extraConfig = ''
    #      autoindex off;
    #      root /share/brogan0/brogan_website/;
    #    '';
    #  };
    #  locations."/live/".return = "301 https://www.youtube.com/watch?v=mS3M0H_NhRg";

    #  locations."/Band-Practice-Recordings/" = {
    #    extraConfig = ''
    #      auth_basic secured;
    #      auth_basic_user_file /var/www/brogan-htpasswd;
    #      autoindex on;
    #      root /share/brogan0/;
    #    '';
    #  };
    #  locations."/Malefactor-Stems/" = {
    #    extraConfig = ''
    #      auth_basic secured;
    #      auth_basic_user_file /var/www/brogan-htpasswd;
    #      autoindex on;
    #      root /share/brogan0/;
    #    '';
    #  };
    #  locations."/bandcamp/" = {
    #    extraConfig = ''
    #      auth_basic secured;
    #      auth_basic_user_file /var/www/brogan-htpasswd;
    #      autoindex on;
    #      root /share/brogan0/;
    #    '';
    #  };
    #};

    virtualHosts."bones.corp.easycashmoney.org" = {
      root = "/var/www/preseed";
      extraConfig = "${serve_files}";
    };
    virtualHosts."isnevadaonfire.org" = {
      root = "/var/www/neb";
      extraConfig = "${serve_files}";
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

                        #on_publish http://localhost:4344/auth;
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
                }
                application test {
                        live on;
                        record off;
                }
        }
      }
    '';

  };
}
