with import <nixpkgs> {};
  {
  systemd.services.fan-control = {
    path = with pkgs; [
      ruby.devEnv
      which
      lm_sensors
      ipmitool
    ];
    description = "R710 Fan Control Script";
    wantedBy = [ "multi-user.target" ];
    after = [ "syslog.target" "network.target" ];
    environment.USER = "root";
    serviceConfig = {
      Type = "simple";
      User = "root";
      Group = "root";
      Restart = "always";
      ExecStartPre = "${pkgs.ruby}/bin/ruby Fan-Control-CLI.rb fanspeed";
      ExecStart = "${pkgs.ruby}/bin/ruby Fan-Control-CLI.rb start";
      WorkingDirectory = "/root/r710-fan-control";
    };
  };
}
