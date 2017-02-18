{ config, pkgs, ... }:

let
  gogspkg = import ./pkgs/gogs/default.nix;
in
{
  imports =
  [
    ./services/ovpn.nix
    ./services/openhab.nix
    ./services/fauxmo.nix
  ];

  # Using UEFI boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.systemPackages = with pkgs; [
    htop
    jenkins
    phantomjs2
    tmux
    tree
    unzip
    wget
    (import ./pkgs/gogs/default.nix)
  ];

  nixpkgs.config.packageOverrides = pkgs: rec {
    jenkins = pkgs.jenkins.overrideDerivation( oldAttrs: {
      src = pkgs.fetchurl {
        url = "http://updates.jenkins-ci.org/download/war/2.46/jenkins.war";
        sha256 = "0d41vpiawj1c128ayhn0p1pim5dmh75lpdzsfskfmm9qwan8isvx";
      };
    });
  };

  users = {
    defaultUserShell = "/run/current-system/sw/bin/bash";
    extraGroups.ssl-cert.gid = 1040;

    extraUsers.henry = {
      isNormalUser = true;
      home = "/home/henry";

      # Configure for sudo, network, gfx, and docker
      extraGroups = ["wheel" "networkmanager" "docker" "ssl-cert" "essentials" ];
      uid = 1000;
      shell = "/run/current-system/sw/bin/bash";
    };

    extraGroups.gogs = {
      name = "gogs";
    };

    extraUsers.gogs = {
      isNormalUser = true;
      home = "/var/lib/gogs";
      extraGroups = ["gogs"];
      useDefaultShell = true;
    };
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
    script =''/var/lib/gogs/gogs web'';
    environment.HOME = "/var/lib/gogs";
    environment.USER = "gogs";
    # Copy gogs and requried files out of /nix/store
    preStart = ''
      # hax
      test -f /var/lib/gogs/skip-copy || {
        touch /var/lib/gogs/skip-copy
        cp -r ${gogspkg}/bin/* /var/lib/gogs/
        chown -R gogs:gogs /var/lib/gogs/
      }
      mkdir -p /var/spool/gogs/
      chown -R gogs:gogs /var/spool/gogs/
    '';
    serviceConfig = {
      PermissionsStartOnly = true;
      Type = "simple";
      User = "gogs";
      Group = "gogs";
      WorkingDirectory="/var/lib/gogs";
      Restart = "always";
    };
  };

  services.jenkins = {
    enable = true;
    extraGroups = [ "essentials" "docker" ];
    port = 8000;
  };

  services.jenkins.packages =
    let env = pkgs.buildEnv {
      name = "jenkins-env";
      pathsToLink = [ "/bin" ];
      paths = [
        pkgs.stdenv pkgs.git pkgs.jdk pkgs.openssh pkgs.nix
        pkgs.gzip pkgs.bash pkgs.wget pkgs.unzip pkgs.glibc pkgs.cmake pkgs.clang
        pkgs.gcc49 pkgs.gnumake pkgs.findutils pkgs.rustcLatest
        pkgs.cargoLatest pkgs.nodejs pkgs.gnutar pkgs.bzip2 pkgs.phantomjs2
      ];
    };
    in [ env ];

  systemd.services.jenkins.serviceConfig.ExecStartPost = pkgs.lib.mkForce "";

  networking = {
    hostName = "quid"; # Define your hostname.
    hostId = "e39841f0";
    firewall.allowedTCPPorts = [ 80 443 3000 42063 8000 8080 52002 52003 ];
    firewall.allowedUDPPorts = [ 80 443 3000 42063 8000 8080 1900 ];
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
