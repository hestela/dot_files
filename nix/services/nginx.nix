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

      ssl_certificate ${ssl_dir}/git.easycashmoney.org/fullchain.pem;
      ssl_certificate_key ${ssl_dir}/git.easycashmoney.org/privkey.pem;
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

      ssl_certificate ${ssl_dir}/git.easycashmoney.org/fullchain.pem;
      ssl_certificate_key ${ssl_dir}/git.easycashmoney.org/privkey.pem;
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

  fastcgiParams =  "include ${pkgs.nginx}/conf/fastcgi_params;";

  # Somewhat functional example of serving up php pages
  phpServer = {url, dir}:
  ''
    server {
      listen 443;
      server_name ${url};

      ssl_certificate ${ssl_dir}/${url}/fullchain.pem;
      ssl_certificate_key ${ssl_dir}/${url}/privkey.pem;
      ssl_dhparam /etc/ssl/certs/dhparam.pem;

      ${ssl_opts}

      root ${dir};
      index index.php;
      location \ {
        try_files $uri /index.php$is_args$args;
      }

      location ~ ^/index\.php(/|$) {
        fastcgi_split_path_info ^(.+\.php)(/.*)$;
        ${fastcgiParams}
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_pass unix:/run/phpfpm/nginx;
      }

      location ~ \.php$ {
        return 404;
      }
    }
  '';

  # Simple local file serving
  fileServer = {url, dir}:
  ''
    server {
      listen 80;
      server_name ${url};

      root ${dir};
      autoindex on;
      location \ {
        deny all;
        allow 192.168.2.0/24;
      }
    }
  '';

  # Simple html server
  htmlServer = {url, dir}:
  ''
    server {
      listen 443;
      server_name ${url};

      ssl_certificate ${ssl_dir}/git.easycashmoney.org/fullchain.pem;
      ssl_certificate_key ${ssl_dir}/git.easycashmoney.org/privkey.pem;
      ssl_dhparam /etc/ssl/certs/dhparam.pem;

      ${ssl_opts}

      root ${dir};
      location \ {
        try_files $uri /index.html;
      }
    }
  '';
in
{
  environment.systemPackages = with pkgs;
  [
    openssl
    letsencrypt
    php
    certbot
  ];

  # SQL
  services.mysql.enable = true;
  services.mysql.package = pkgs.mysql;
  services.mysql.dataDir = "/var/db/mysql";
  systemd.services.mysql.serviceConfig.Restart = "on-failure";
  systemd.services.mysql.serviceConfig.RestartSec = "10s";

  services.nginx = {
    enable = true;
    config = ''
      http {
        server {
          listen 80;
          return 301 https://$host$request_uri;
        }

        ${localhostReverseProxy { url = "ci.easycashmoney.org"; port = 8000; }}
        ${localhostReverseProxy { url = "git.easycashmoney.org"; port = 1111; }}
        ${unifiProxy { url = "unifi.easycashmoney.org"; port = 8443; }}
        ${fileServer { url = "dinero-serv.corp.easycashmoney.org"; dir = "/var/www/preseed"; }}

        #{phpServer { url = "calendar.easycashmoney.org"; dir = "/var/www/agendav-test/web/public"; }}
        ${htmlServer { url = "calendar.easycashmoney.org"; dir = "/var/www/public-test"; }}
      }
      events {
        worker_connections 768;
      }
    '';
  };

  services.phpfpm.poolConfigs.nginx = ''
    listen = /run/phpfpm/nginx
    listen.owner = nginx
    listen.group = nginx
    listen.mode = 0660
    user = nginx
    pm = dynamic
    pm.max_children = 75
    pm.start_servers = 10
    pm.min_spare_servers = 5
    pm.max_spare_servers = 20
    pm.max_requests = 500
    php_flag[display_errors] = off
    php_admin_value[error_log] = "/run/phpfpm/php-fpm.log"
    php_admin_flag[log_errors] = on
    php_value[date.timezone] = "UTC"
    php_value[upload_max_filesize] = 10G
    env[PATH] = /srv/www/bin:/var/setuid-wrappers:/srv/www/.nix-profile/bin:/srv/www/.nix-profile/sbin:/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin:/run/current-system/sw/bin/run/current-system/sw/sbin
  '';
}
