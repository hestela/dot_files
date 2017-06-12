{ config, pkgs, ... }:

let
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
  '';
  ssl_dir = ''/etc/letsencrypt/live'';

  localhostReverseProxy = {url, port}:
  ''
    server {
      listen 443;
      server_name ${url};

      ssl_certificate ${ssl_dir}/${url}/fullchain.pem;
      ssl_certificate_key ${ssl_dir}/${url}/privkey.pem;
      ssl_dhparam /etc/ssl/certs/dhparam.pem;

      ${ssl_opts}

        ssl_trusted_certificate /etc/ssl/certs/unifi.pem;

      location / {
        proxy_set_header        Host $host;
        proxy_set_header        X-Real-IP $remote_addr;
        proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header        X-Forwarded-Proto $scheme;

        proxy_read_timeout  90;
        chunked_transfer_encoding off;

        proxy_pass          http://localhost:${toString port};
        proxy_redirect      http://localhost:${toString port} https://${url};
      }
    }
  '';

  # Unifi redirects to https and can't be disabled
  unifiProxy = {url, port}:
  ''
    server {
      listen 443;
      server_name ${url};

      ssl_certificate ${ssl_dir}/${url}/fullchain.pem;
      ssl_certificate_key ${ssl_dir}/${url}/privkey.pem;
      ssl_dhparam /etc/ssl/certs/dhparam.pem;

      ${ssl_opts}
      ssl_trusted_certificate /etc/ssl/certs/unifi.pem;

      location / {
        proxy_set_header        Host $host;
        proxy_set_header        X-Real-IP $remote_addr;
        proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header        X-Forwarded-Proto $scheme;

        proxy_read_timeout  90;
        chunked_transfer_encoding off;

        proxy_pass          https://localhost:${toString port};
        proxy_redirect      https://localhost:${toString port} https://${url};
      }
    }
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

        ${localhostReverseProxy { url = "ci.easycashmoney.org"; port = 8000; }}
        ${localhostReverseProxy { url = "git.easycashmoney.org"; port = 3000; }}
        ${unifiProxy { url = "unifi.easycashmoney.org"; port = 8443; }}
      }
      events {
        worker_connections 768;
      }
    '';
  };
}
