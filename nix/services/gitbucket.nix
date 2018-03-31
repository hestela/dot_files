{ config, pkgs, ... }:

let
  gitbucketpkg = import ../pkgs/gitbucket.nix;
in
{
#  networking.firewall.allowedTCPPorts = [ 8080 ];
  systemd.services.gitbucket = {
    path = with pkgs; [
     jdk
     (import ../pkgs/gitbucket.nix)
     gnumake
     gcc
     autoconf
     automake
     libtool
     coreutils
    ];
    description = "GitBucket is a Git web platform powered by Scala";
    wantedBy = [ "multi-user.target" ];
    after = [ "syslog.target" "network.target" ];
    environment.USER = "root";
    serviceConfig = {
      Type = "simple";
      User = "root";
      Group = "root";
      Restart = "always";
      ExecStart = "${pkgs.jdk}/bin/java -jar ${gitbucketpkg}/gitbucket.war --gitbucket.home=/root/gitbucket";
    };
  };
}
