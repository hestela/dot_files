{ config, pkgs, ... }:

{
  imports =
  [
    ../services/gitbucket.nix
  ];

  # Using UEFI boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.avahi.enable = true;

  environment.systemPackages = with pkgs; [
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
        url = "http://updates.jenkins-ci.org/download/war/2.107.1/jenkins.war";
        sha256 = "100jnd31v4jjc5wjdbm3mgwfmcnx97vd41fpap7gdl8f3604riyf";
      };
    });
  };

 # virtualisation.docker.listenOptions = [ "/var/run/docker.sock" "tcp://0.0.0.0:4243" ];
  virtualisation.docker.extraOptions = "-H tcp://0.0.0.0:4243";
  services.jenkins = {
    enable = true;
    extraGroups = [ "docker" ];
    port = 8000;
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
  };

  networking = {
    hostName = "dinero";
    firewall.allowedTCPPorts = [ 80 443 3000 42063 8080 8443 7080 1111 8000 ];
    firewall.allowedUDPPorts = [ 80 443 3000 42063 8080 1900 8000 ];
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
