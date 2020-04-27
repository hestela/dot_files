{ config, pkgs, ... }:

{
  imports =
  [
    ../services/openhab.nix
    ../services/fauxmo.nix
    ../services/nginx.nix
    ../services/unifi.nix
    ../services/dnsmasq.nix
    ../services/samba-serv.nix
    ../services/kraplow.nix
    ../services/jitsi.nix
    ../services/airsonic.nix
    #../services/murmur.nix
    #../services/wireguard.nix
  ];

  fileSystems."/mnt/repos" = {
    device = "192.168.2.82:/nfs/repos";
    fsType = "nfs";
  };

  nixpkgs.config.allowUnfree = true;

  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
     /opt/kickstarts *(rw,nohide,insecure,no_subtree_check)
     /opt/nfs *(rw,nohide,insecure,no_subtree_check)
  '';

  boot = {
    # Using GRUB boot
    loader = {
      grub.enable = true;
      grub.version = 2;
      grub.device = "/dev/sda";
      grub.configurationLimit = 10;
    };

    kernelModules = [
      "ipmi_devintf"
      "ipmi_si"
    ];
  };

  # Open up ipmitool
  services.udev.extraRules = ''
    KERNEL=="ipmi*", MODE="0666"
  '';

  services.avahi.enable = true;

  environment.systemPackages = with pkgs; [
    (import ../pkgs/bible.nix)
    geekbench
    #(import ../pkgs/pxeconfig.nix)
    ffmpeg-full
    htop
    iperf
    iperf2
    ipmitool
    jenkins
    jre
    tmux
    tree
    unzip
    wget
    python27Packages.virtualenv
    python36Packages.virtualenv
    vsftpd
    xinetd
    inetutils
    syslinux
  ];

  nixpkgs.config.packageOverrides = pkgs: rec {
    jenkins = pkgs.jenkins.overrideDerivation( oldAttrs: {
      src = pkgs.fetchurl {
        url = "http://mirrors.jenkins.io/war-stable/2.176.3/jenkins.war";
        sha256 = "18wsggb4fhlacpxpxkd04zwj56gqjccrbkhs35vkyixwwazcf1ll";
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
          pkgs.python27
        ];
      };
      in [ env ];
  };

  # TESTING gitbucket
  systemd.services.gitbucket = {
    path = with pkgs; [
      git
      sqlite
      openssh
      bash
      jre
    ];
    description = "GitBucket (Git Service)";
    wantedBy = [ "multi-user.target" ];
    after = [ "syslog.target" "network.target" ];
    script =''java -jar /opt/gitbucket/gitbucket.war --port=2222'';
    environment.HOME = "/opt/gitbucket";
    environment.USER = "gitbucket";
    serviceConfig = {
      PermissionsStartOnly = true;
      Type = "simple";
      User = "gitbucket";
      Group = "gogs";
      WorkingDirectory="/opt/gitbucket";
      Restart = "always";
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
    script =''/opt/gogs/gogs web'';
    environment.HOME = "/opt/gogs/";
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

    extraGroups.fileshare= {
      name = "fileshare";
    };

    extraUsers.gogs = {
      isNormalUser = true;
      home = "/opt/gogs";
      extraGroups = ["gogs"];
      useDefaultShell = true;
    };

    extraUsers.gitbucket= {
      isNormalUser = true;
      home = "/opt/gitbucket";
      extraGroups = ["gogs"];
      useDefaultShell = true;
    };

    extraUsers.broganohara = {
      isNormalUser = true;
      home = "/home/broganohara";
      useDefaultShell = true;
      extraGroups = ["fileshare"];
    };
  };

  networking = {
    hostName = "bones";
    domain = "corp.easycashmoney.org";
    firewall.allowedTCPPorts = [ 80 111 443 2049 42063 51820 7000 ];
    firewall.allowedUDPPorts = [ 69 80 111 2049 443 42063 ];
    firewall.allowPing = true;
  };

  services.openssh = {
    enable = true;
    ports = [ 42063 ];
    passwordAuthentication = false;
    #macs = [
    #      "hmac-sha2-512-etm@openssh.com"
    #      "hmac-sha2-256-etm@openssh.com"
    #      "umac-128-etm@openssh.com"
    #      "hmac-sha2-512"
    #      "hmac-sha2-256"
    #      "umac-128@openssh.com"
    #      # Workaround for android ssh vpn app supporting only old MACs.
    #      "hmac-sha1"
    #    ];
  };

  users.users.henry.openssh.authorizedKeys.keys = [
     "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxx9Up0yJ/txCDtZRL7rb1qCfU5Hh81Il53OKMTF7EkTB2V915amgoHdjdTac2TisIasq9uNIpmZ8GA1mEICBa9A+enk31k/AI3DC6LwfPIOh+rdueB+acuhE8keTENEdwiwZ5KtiCELtCEidA0mPxu2n5tLPGk+u871/Coes73csHtMgLzI5nQkGZSwbjWSBcMzOjGKF9fhpoItQpZHt4kKTyZkpfKU4pvT8vNcyAPNQsQ4BXHfofl02n8qUDgZ/DeNgzBc4efuMiSFKOnUQd0cHLQVAYIjvj91WohiqblmkdarDLMZJ67x9qjhrK/epUCh/F48EKtUFPrSghW6vV henryestela@gmail.com"
  ];
  users.users.broganohara.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDSnaPcox1mKl6gpDMQzhk4UByzzXITH1JZOzq8r8rOuY3OAyDwzhwxkUdP5tLOPusTemSZKzmXCIGLiYiFOfq3Q0+biB+aji+l22DXLKcwL4GAyPA9FI4P80+91YR1JYFSFVOsKHZnbP0g/Iv9rLL3KlDTOCtrNuT5qod9lzdzzF4NC0uLp0JURVHnNGQxOKB1o1pAARtGiRUo2T5DfnCKg72qcmbNOTJTGMIW+AyGXb5aO4s4tEppcOsBJ+q955aAiK21MdB4rlEW6UE4xt/+Kv2w7vSbZgpJ8rSRLl5auLsgs9F4zuWLCCbVvx8jWFQZf0IjG6IOI8CY+uq2HPCd Generated By Termius"
  ];
}
