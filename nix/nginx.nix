{ config, pkgs, ... }:

let
  ssl_dir = ''/etc/letsencrypt/live/'';
  ssl_opts = ''
    ssl on;
    ssl_session_cache  builtin:1000  shared:SSL:10m;
    ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES257+EECDH:AES256+EDH";
    ssl_prefer_server_ciphers on;
    ssl_ecdh_curve secp384r1;
    ssl_session_cache shared:SSL:10m;
    ssl_session_tickets off;
    ssl_stapling on;
    ssl_stapling_verify on;
    resolver_timeout 5s;
    add_header Strict-Transport-Security "max-age=63072000;
    includeSubDomains; preload";
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    ssl_dhparam /etc/ssl/certs/dhparam.pem;
  '';

  listen_opts = ''
    listen 443;
    location /.well-known/acme-challenge {
      root /var/www/challenges;
    }
  '';

  location_opts = ''
    proxy_set_header        Host $host;
    proxy_set_header        X-Real-IP $remote_addr;
    proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header        X-Forwarded-Proto $scheme;
    proxy_read_timeout  90;
    chunked_transfer_encoding off;
  '';
in
{
  environment.systemPackages = with pkgs;
  [
    openssl
    letsencrypt
  ];

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
            server_name ci.easycashmoney.org;

            ssl_certificate ${ssl_dir}/ci.easycashmoney.org/fullchain.pem;
            ssl_certificate_key ${ssl_dir}/ci.easycashmoney.org/privkey.pem;
            ${ssl_opts}
            ${listen_opts}

            location / {
              proxy_pass          http://localhost:8000;
              proxy_redirect      http://localhost:8000 https://ci.easycashmoney.org;
              ${location_opts}
            }
        }
        # gogs
        server {
            server_name git.easycashmoney.org;

            ssl_certificate ${ssl_dir}/git.easycashmoney.org/fullchain.pem;
            ssl_certificate_key ${ssl_dir}/git.easycashmoney.org/privkey.pem;
            ${ssl_opts}
            ${listen_opts}

            location / {
              proxy_pass          http://localhost:3000;
              proxy_redirect      http://localhost:3000 https://git.easycashmoney.org;
              ${location_opts}
            }
        }
        # OpenHab 2
        server {
            server_name oh2.easycashmoney.org;
            auth_basic "OpenHab2";
            auth_basic_user_file /var/www/.htpasswd;

            ssl_certificate ${ssl_dir}/oh2.easycashmoney.org/fullchain.pem;
            ssl_certificate_key ${ssl_dir}/oh2.easycashmoney.org/privkey.pem;
            ${ssl_opts}
            ${listen_opts}

            location / {
              proxy_pass          http://localhost:8080;
              proxy_redirect      http://localhost:8080 https://oh2.easycashmoney.org;
              ${location_opts}
            }
        }
      }
      events {
        worker_connections 768;
      }
    '';
  };
}
