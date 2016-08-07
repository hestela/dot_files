{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    letsencrypt                      # Auto SSL Cert
    jenkins
  ];

  services.jenkins = {
    enable = true;
    extraGroups = [ "essentials" ];
    port = 8000;
  };

  services.jenkins.packages =
    let env = pkgs.buildEnv {
      name = "jenkins-env";
      pathsToLink = [ "/bin" ];
      paths = [
        pkgs.stdenv pkgs.git pkgs.jdk pkgs.openssh pkgs.nix
        pkgs.gzip pkgs.bash pkgs.wget pkgs.unzip pkgs.glibc pkgs.cmake pkgs.clang
        pkgs.gcc49
      ];
    };
    in [ env ];

  systemd.services.jenkins.serviceConfig.TimeoutStartSec = "10min";

  networking = {
    hostName = "quid"; # Define your hostname.
    hostId = "e39841f0";
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
