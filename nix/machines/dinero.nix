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
    vsftpd
    xinetd
    inetutils
    syslinux
  ];

  nixpkgs.config.packageOverrides = pkgs: rec {
    jenkins = pkgs.jenkins.overrideDerivation( oldAttrs: {
      src = pkgs.fetchurl {
        url = "http://updates.jenkins-ci.org/download/war/2.121.2/jenkins.war";
        sha256 = "00ln31ahhsihnxba2hldrjxdpyxl7xw731493a24cqlkdq89s3ys";
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
    firewall.allowedTCPPorts = [ 80 111 443 2049 42063 51820 7000 ];
    firewall.allowedUDPPorts = [ 69 80 111 2049 443 42063 ];
  };

  services.openssh = {
    enable = true;
    ports = [ 42063 ];
    passwordAuthentication = false;
    #extraConfig = ''
    #  MACs hmac-ripemd160
    #'';
    #macs = [
    #      "hmac-sha2-512-etm@openssh.com"
    #      "hmac-sha2-256-etm@openssh.com"
    #      "umac-128-etm@openssh.com"
    #      "hmac-sha2-512"
    #      "hmac-sha2-256"
    #      "umac-128@openssh.com"
    #    ];
  };

  # Waiting for new nixos build for sshd mac option
  systemd.services.sshd.serviceConfig.ExecStart = pkgs.lib.mkForce "${pkgs.openssh}/bin/sshd";

  # Workaround for android ssh vpn app supporting only old MACs.
  # Nixos not updated with latest mac options
  environment.etc."ssh/sshd_config".text = ''
      Protocol 2
      UsePAM yes
      AddressFamily inet
      Port 42063

      X11Forwarding no

      Subsystem sftp ${pkgs.openssh}/libexec/sftp-server

      PermitRootLogin prohibit-password
      GatewayPorts no
      PasswordAuthentication no
      ChallengeResponseAuthentication yes

      PrintMotd no # handled by pam_motd

      AuthorizedKeysFile .ssh/authorized_keys .ssh/authorized_keys2 /etc/ssh/authorized_keys.d/%u

      HostKey /etc/ssh/ssh_host_rsa_key
      HostKey /etc/ssh/ssh_host_ed25519_key


      ### Recommended settings from both:
      # https://stribika.github.io/2015/01/04/secure-secure-shell.html
      # and
      # https://wiki.mozilla.org/Security/Guidelines/OpenSSH#Modern_.28OpenSSH_6.7.2B.29

      KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
      Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
      MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com,hmac-sha1

      # LogLevel VERBOSE logs user's key fingerprint on login.
      # Needed to have a clear audit track of which key was used to log in.
      LogLevel VERBOSE
    '';

  users.users.henry.openssh.authorizedKeys.keys = [
     "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxx9Up0yJ/txCDtZRL7rb1qCfU5Hh81Il53OKMTF7EkTB2V915amgoHdjdTac2TisIasq9uNIpmZ8GA1mEICBa9A+enk31k/AI3DC6LwfPIOh+rdueB+acuhE8keTENEdwiwZ5KtiCELtCEidA0mPxu2n5tLPGk+u871/Coes73csHtMgLzI5nQkGZSwbjWSBcMzOjGKF9fhpoItQpZHt4kKTyZkpfKU4pvT8vNcyAPNQsQ4BXHfofl02n8qUDgZ/DeNgzBc4efuMiSFKOnUQd0cHLQVAYIjvj91WohiqblmkdarDLMZJ67x9qjhrK/epUCh/F48EKtUFPrSghW6vV henryestela@gmail.com"
  ];
}
