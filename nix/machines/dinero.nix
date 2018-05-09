{ config, pkgs, ... }:

{
  imports =
  [
    ../services/openhab.nix
    ../services/fauxmo.nix
    ../services/nginx.nix
    ../services/unifi.nix
  ];

  # Using UEFI boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.avahi.enable = true;

  environment.systemPackages = with pkgs; [
    (import ../pkgs/bible.nix)
    htop
    iperf
    iperf2
    jenkins
    jre
    tmux
    tree
    unzip
    wget
  ];

  nixpkgs.config.packageOverrides = pkgs: rec {
    jenkins = pkgs.jenkins.overrideDerivation( oldAttrs: {
      src = pkgs.fetchurl {
        url = "http://updates.jenkins-ci.org/download/war/2.107.2/jenkins.war";
        sha256 = "1vb7mrsbc1nfkcvpqb8zhsp2yxcnl82dhzd5sba3vsklps2vi6h7";
      };
    });
  };

  virtualisation.docker.extraOptions = "-H tcp://0.0.0.0:4243";
  services.jenkins = {
    enable = true;
    extraGroups = [ "docker" ];
    port = 8000;
    home = "/opt/jenkins";
    packages =
      let env = pkgs.buildEnv {
        name = "jenkins-env";
        pathsToLink = [ "/bin" ];
        paths = [
          # TODO: figure out what is needed
          pkgs.stdenv pkgs.git pkgs.jdk pkgs.openssh
          pkgs.gzip pkgs.bash pkgs.wget pkgs.unzip
          pkgs.gnutar pkgs.bzip2 pkgs.gitRepo pkgs.docker
        ];
      };
      in [ env ];
  };

  systemd.services.gogs = {
    path = with pkgs; [
      git
      sqlite
      openssh
      bash
    ];
    description = "Gogs (Go Git Service)";
    wantedBy = [ "multi-user.target" ];
    after = [ "syslog.target" "network.target" ];
    script =''/opt/gogs/gogs web'';
    environment.HOME = "/opt/gogs";
    environment.USER = "gogs";
    serviceConfig = {
      PermissionsStartOnly = true;
      Type = "simple";
      User = "gogs";
      Group = "gogs";
      WorkingDirectory="/opt/gogs";
      Restart = "always";
    };
  };

  users = {
    defaultUserShell = "/run/current-system/sw/bin/bash";
    extraGroups.ssl-cert.gid = 1040;

    extraUsers.henry = {
      isNormalUser = true;
      home = "/home/henry";

      # Configure for sudo, network, gfx, and docker
      extraGroups = ["wheel" "docker" "ssl-cert" ];
      uid = 1000;
      shell = "/run/current-system/sw/bin/bash";
    };
    extraGroups.gogs = {
      name = "gogs";
    };

    extraUsers.gogs = {
      isNormalUser = true;
      home = "/opt/gogs";
      extraGroups = ["gogs"];
      useDefaultShell = true;
    };
  };

  networking = {
    hostName = "dinero";
    firewall.allowedTCPPorts = [ 80 443 42063 ];
    firewall.allowedUDPPorts = [ 80 443 42063 ];
  };

  services.openssh = {
    enable = true;
    ports = [ 42063 ];
    passwordAuthentication = false;
  };

  users.users.henry.openssh.authorizedKeys.keys = [
     "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxx9Up0yJ/txCDtZRL7rb1qCfU5Hh81Il53OKMTF7EkTB2V915amgoHdjdTac2TisIasq9uNIpmZ8GA1mEICBa9A+enk31k/AI3DC6LwfPIOh+rdueB+acuhE8keTENEdwiwZ5KtiCELtCEidA0mPxu2n5tLPGk+u871/Coes73csHtMgLzI5nQkGZSwbjWSBcMzOjGKF9fhpoItQpZHt4kKTyZkpfKU4pvT8vNcyAPNQsQ4BXHfofl02n8qUDgZ/DeNgzBc4efuMiSFKOnUQd0cHLQVAYIjvj91WohiqblmkdarDLMZJ67x9qjhrK/epUCh/F48EKtUFPrSghW6vV henryestela@gmail.com"
  ];
}
