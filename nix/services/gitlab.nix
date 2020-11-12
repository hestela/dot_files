{ config, pkgs, ... }:
let
  acme ="easycashmoney.org";
  gitlab_url = "gitlab.easycashmoney.org";
  cert_dir = "/var/gitlab/state/home/";
in
{
  services.nginx = {
    virtualHosts."gitlab.easycashmoney.org" = {
      useACMEHost = "${acme}";
      forceSSL = true;
      locations."/".proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
      locations."/v2" = {
        proxyPass = "http://localhost:5000";
        extraConfig = ''
          chunked_transfer_encoding on;
          client_max_body_size 0;
          add_header Docker-Distribution-Api-Version "registry/2.0";
          if ($http_user_agent ~ "^(docker\/1\.(3|4|5(?!\.[0-9]-dev))|Go ).*$" ) {
            return 404;
          }
        '';
      };
    };
  };

  services.dockerRegistry = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 5000;
    extraConfig = {
      REGISTRY_AUTH_TOKEN_REALM = "https://${gitlab_url}/jwt/auth";
      REGISTRY_AUTH_TOKEN_SERVICE = "container_registry";
      REGISTRY_AUTH_TOKEN_ISSUER = "gitlab-issuer";
      REGISTRY_AUTH_TOKEN_ROOTCERTBUNDLE = "${cert_dir}/domain.crt";
      REGISTRY_HTTP_TLS_CERTIFICATE = "${cert_dir}/domain.crt";
      REGISTRY_HTTP_TLS_KEY = "${cert_dir}/domain.key";
    };
  };

  services.gitlab = {
    enable = true;
    databasePasswordFile = "/var/keys/gitlab/db_password";
    initialRootPasswordFile = "/var/keys/gitlab/root_password";
    https = true;
    host = "gitlab.easycashmoney.org";
    user = "git";
    group = "git";
    port = 443;
    databaseUsername = "git";
    smtp = {
      enable = true;
      domain = "smtp.zoho.com";
      username = "admin@easycashmoney.org";
      passwordFile = "/var/keys/gitlab/smtp";
      port = 587;
    };
    secrets = {
      dbFile = "/var/keys/gitlab/db";
      secretFile = "/var/keys/gitlab/secret";
      otpFile = "/var/keys/gitlab/otp";
      jwsFile = "/var/keys/gitlab/jws";
    };
    extraConfig = {
      gitlab = {
        email_from = "info@easycashmoney.org";
        email_display_name = "Easycashmoney GitLab";
        email_reply_to = "info@easycashmoney.org";
      };
      registry = {
        enabled = true;
        host = "gitlab.easycashmoney.org";
        port = "443";
        key = "/var/lib/acme/easycashmoney.org/key.pem";
        api_url = "http://localhost:5000/";
        issuer = "gitlab-issuer";
      };
      packages = { enabled = true; };
    };
  };

  services.gitlab-runner = {
    enable = true;
    configFile = "/opt/gitlab/runner.toml";
  };
}
