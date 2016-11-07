{ config, pkgs, ... }:

let
  ssl_opts = ''
    ssl on;
    ssl_session_cache  builtin:1000  shared:SSL:10m;
    ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers HIGH:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:!MD5:!PSK:!RC4;
    ssl_prefer_server_ciphers on;
  '';
in
{
  environment.systemPackages = with pkgs;
  [
    openssl
    letsencrypt
  ];

  security.acme.certs."ci.easycashmoney.org" = {
    email = "admin@easycashmoney.org";
    webroot = "/var/www/challenges/";
    user = "nginx";
    postRun = "systemctl restart nginx.service";
  };

  security.acme.certs."git.easycashmoney.org" = {
    email = "admin@easycashmoney.org";
    webroot = "/var/www/challenges/";
    user = "nginx";
    postRun = "systemctl restart nginx.service";
  };

  services.nginx = {
    enable = true;
    config = ''
      http {
        server {
          listen 80;
          return 301 https://$host$request_uri;
        }
        # jenkins
        server {
            listen 443;
            server_name ci.easycashmoney.org;

            ssl_certificate ${config.security.acme.directory}/ci.easycashmoney.org/fullchain.pem;
            ssl_certificate_key ${config.security.acme.directory}/ci.easycashmoney.org/key.pem;
            ${ssl_opts}

            location /.well-known/acme-challenge {
              root /var/www/challenges;
            }

            location / {
              proxy_set_header        Host $host;
              proxy_set_header        X-Real-IP $remote_addr;
              proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header        X-Forwarded-Proto $scheme;

              # Fix the “It appears that your reverse proxy set up is broken" error.
              proxy_pass          http://localhost:8000;
              proxy_read_timeout  90;

              proxy_redirect      http://localhost:8000 https://ci.easycashmoney.org;
              chunked_transfer_encoding off;
            }
        }
        # gogs
        server {
            listen 443;
            server_name git.easycashmoney.org;

            ssl_certificate ${config.security.acme.directory}/git.easycashmoney.org/fullchain.pem;
            ssl_certificate_key ${config.security.acme.directory}/git.easycashmoney.org/key.pem;
            ${ssl_opts}

            location /.well-known/acme-challenge {
              root /var/www/challenges;
            }

            location / {
              proxy_set_header        Host $host;
              proxy_set_header        X-Real-IP $remote_addr;
              proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header        X-Forwarded-Proto $scheme;

              # Fix the “It appears that your reverse proxy set up is broken" error.
              proxy_pass          http://localhost:3000;
              proxy_read_timeout  90;

              proxy_redirect      http://localhost:3000 https://git.easycashmoney.org;
              chunked_transfer_encoding off;
            }
        }
      }
      events {
        worker_connections 768;
      }
    '';
  };
}
