{ config, pkgs, ... }:

let
  ssl_dir = ''/etc/letsencrypt/live/easycashmoney.org-0001/'';
  ssl_opts = ''
    ssl on;
    ssl_session_cache  builtin:1000  shared:SSL:10m;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers "EECDH+AESGCM:EDH+AESGCM";
    ssl_prefer_server_ciphers on;
    ssl_ecdh_curve secp384r1;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout  10m;
    ssl_session_tickets off;
    ssl_stapling on;
    ssl_stapling_verify on;
    resolver_timeout 5s;
    add_header Strict-Transport-Security "max-age=63072000;
    includeSubDomains; preload";
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;

    ssl_certificate ${ssl_dir}/fullchain.pem;
    ssl_certificate_key ${ssl_dir}/privkey.pem;
    ssl_dhparam /etc/ssl/certs/dhparam.pem;
  '';

  localhostReverseProxy = {url, port}:
  ''
    server {
      listen 443;
      server_name ${url};

      ${ssl_opts}

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

  # Simple public file serving with ssl and password
  fileServerSec = {url, dir}:
  ''
    server {
      listen 443;
      server_name ${url};

      # FIXME: this could be broken with new cert
      ${ssl_opts}

      root ${dir};
      auth_basic "Secret Files";
      auth_basic_user_file /var/www/brogan-htpasswd;
      autoindex on;
      location ~ ^.*/(?P<request_basename>[^/]+\.(zip|MOV|mov))$ {
        root ${dir};
        add_header Content-Disposition 'attachment; filename="$request_basename"';
      }
    }
  '';

  # Simple html server
  htmlServer = {url, dir}:
  ''
    server {
      listen 443;
      server_name ${url};

      ${ssl_opts}

      root ${dir};
      location \ {
        try_files $uri /index.html;
      }
    }
  '';
in
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
        # GOGS
        ${localhostReverseProxy { url = "git.easycashmoney.org"; port = 1111; }}
        ${unifiProxy { url = "unifi.easycashmoney.org"; port = 8443; }}
        ${fileServer { url = "bones.corp.easycashmoney.org"; dir = "/var/www/preseed"; }}

        # TESTING
        #{localhostReverseProxy { url = "easycashmoney.org"; port = 2222; }}
        ${fileServerSec { url = "easycashmoney.org"; dir = "/var/www/files"; }}

        #{phpServer { url = "calendar.easycashmoney.org"; dir = "/var/www/agendav-test/web/public"; }}
        ${fileServerSec { url = "music.easycashmoney.org"; dir = "/share/brogan0/"; }}
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
