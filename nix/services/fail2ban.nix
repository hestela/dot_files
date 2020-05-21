{ config, pkgs, ... }:
{
  services.fail2ban = {
    enable = true;
    jails.nginx = ''
      logpath = /var/log/nginx-error.log
      enabled = true
      filter   = nginx
      action = iptables-multiport[name=NGINXBOT, port=http,https, protocol=tcp]
      maxretry = 5
    '';
    jails.nginx-lanonly = ''
      enabled = true
      filter   = nginx-lanonly
      action = iptables-multiport[name=NGINXLANONLY, port=http,https, protocol=tcp]
      maxretry = 5
    '';
  };

  environment.etc = {
    # [error] 18597#18597: *6 open() "/var/www/files/favicon.ico" failed (2: No such file or directory), client: 192.168.2.1, server: easycashmoney.org, request: "GET /favicon.ico HTTP/2.0", host: "easycashmoney.org", referrer: "https://easycashmoney.org/link.html"
    "fail2ban/filter.d/nginx.conf".text = ''
        [INCLUDES]
        # Load regexes for filtering
        before = botsearch-common.conf

        [Definition]
        failregex = ^ \[error\] \d+#\d+: \*\d+ (\S+ )?\"\S+\" (failed|is not found) \(2\: No such file or directory\), client\: <HOST>\, server\: \S*\, request: \"(GET|POST|HEAD) \/<block> \S+\"\, .*?$
        ignoreregex =
    '';
    # [error] 18597#18597: *23 access forbidden by rule, client: 195.54.160.123, server: bones.corp.easycashmoney.org, request: "GET /index.php?s=/Index/\think\app/invokefunction&function=call_user_func_array&vars[0]=md5&vars[1][]=HelloThinkPHP HTTP/1.1", host: "76.102.52.24:80"
    "fail2ban/filter.d/nginx-lanonly.conf".text = ''
        [Definition]
        failregex = ^ \[error\] \d+#\d+: .* forbidden .*, client: <HOST>, .*$
        ignoreregex =
    '';
  };
}
