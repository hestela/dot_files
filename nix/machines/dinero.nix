{ config, pkgs, ... }:

{
  imports =
  [
    ../services/openhab.nix
    ../services/fauxmo.nix
    ../services/nginx.nix
    ../services/unifi.nix
    ../services/dnsmasq.nix
  ];

  fileSystems."/mnt/repos" = {
    device = "192.168.2.82:/nfs/repos";
    fsType = "nfs";
  };

  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
     /opt/kickstarts *(rw,nohide,insecure,no_subtree_check)
     /opt/nfs *(rw,nohide,insecure,no_subtree_check)
  '';

  boot = {
    # Using UEFI boot
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
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
    (import ../pkgs/discord.nix)
    vsftpd
    xinetd
    inetutils
    syslinux
  ];

  nixpkgs.config.packageOverrides = pkgs: rec {
    jenkins = pkgs.jenkins.overrideDerivation( oldAttrs: {
      src = pkgs.fetchurl {
        url = "http://mirrors.jenkins.io/war-stable/2.150.1/jenkins.war";
        sha256 = "0sb6mzynw1vg6s43mpd7b0dz1clbf8akga09i14q66isb9nmhf3s";
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
    extraUsers.neb = {
      isNormalUser = true;
      home = "/home/neb";

      # Configure for sudo, network, gfx, and docker
      extraGroups = ["docker"];
      uid = 5000;
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
    domain = "corp.easycashmoney.org";
    firewall.allowedTCPPorts = [ 80 111 443 2049 42063 51820 7000 ];
    firewall.allowedUDPPorts = [ 69 80 111 2049 443 42063 ];
  };

  services.openssh = {
    enable = true;
    ports = [ 42063 ];
    passwordAuthentication = false;
    macs = [
          "hmac-sha2-512-etm@openssh.com"
          "hmac-sha2-256-etm@openssh.com"
          "umac-128-etm@openssh.com"
          "hmac-sha2-512"
          "hmac-sha2-256"
          "umac-128@openssh.com"
          # Workaround for android ssh vpn app supporting only old MACs.
          "hmac-sha1"
        ];
  };

  users.users.neb.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDWwYSzSfW2W52TRZCjkk20n0O7cOqLSyxKWG0foXWeqe1G6JVWyq+OchtRM+7gGhX5LGcl5Lena5wNXU3cIY7nHHXxdV/YjdSWxwRs0xzcBxXdrY55doItU6Qb2b7IpFwrRIE0fibVZmDnS5G5M4tDBf+Kus6/ZboYjwJLbiViC7DcYW5S5M8YsdGZWWNDJWAmE+4mBlcF3XZlqHdTmWH06fuEDs/h9Z97GwuK4dfU8Zfxek6kihgbPIg1Tuf8cSRK/1et79sPE36GAPCYU2C4VasW+9LZ8Y8u8npx92QSiKNZETKfnN6UW9JMEHY5bEeUnuBvuYXjHsUk9CcYTO/V neb@dinero"
  ];

  users.users.henry.openssh.authorizedKeys.keys = [
     "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxx9Up0yJ/txCDtZRL7rb1qCfU5Hh81Il53OKMTF7EkTB2V915amgoHdjdTac2TisIasq9uNIpmZ8GA1mEICBa9A+enk31k/AI3DC6LwfPIOh+rdueB+acuhE8keTENEdwiwZ5KtiCELtCEidA0mPxu2n5tLPGk+u871/Coes73csHtMgLzI5nQkGZSwbjWSBcMzOjGKF9fhpoItQpZHt4kKTyZkpfKU4pvT8vNcyAPNQsQ4BXHfofl02n8qUDgZ/DeNgzBc4efuMiSFKOnUQd0cHLQVAYIjvj91WohiqblmkdarDLMZJ67x9qjhrK/epUCh/F48EKtUFPrSghW6vV henryestela@gmail.com"
  ];
}
