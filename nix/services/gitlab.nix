{ config, pkgs, ... }:
{
  services.nginx = {

    virtualHosts."gitlab.easycashmoney.org" = {
      forceSSL = true;
      locations."/".proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
      useACMEHost = "easycashmoney.org";
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
        api_url = "http://localhost:5000";
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
