{ config, pkgs, ... }:

{
  services.openssh = {
    enable = true;
    ports = [ 42063 ];
    passwordAuthentication = false;
    extraConfig = ''
      KexAlgorithms diffie-hellman-group1-sha1,
      diffie-hellman-group16-sha512,
      diffie-hellman-group18-sha512,
      diffie-hellman-group-exchange-sha1,
      diffie-hellman-group-exchange-sha256,
      ecdh-sha2-nistp256,
      ecdh-sha2-nistp384,
      ecdh-sha2-nistp521,
      curve25519-sha256,
      curve25519-sha256@libssh.org

      HostKeyAlgorithms ssh-ed25519,
      ssh-ed25519-cert-v01@openssh.com,
      ssh-dss,
      ecdsa-sha2-nistp256,
      ecdsa-sha2-nistp384,
      ecdsa-sha2-nistp521,
      ssh-rsa-cert-v01@openssh.com,
      ssh-dss-cert-v01@openssh.com,
      ecdsa-sha2-nistp256-cert-v01@openssh.com,
      ecdsa-sha2-nistp384-cert-v01@openssh.com,
      ecdsa-sha2-nistp521-cert-v01@openssh.com

      MACs
      hmac-sha1-96
      hmac-sha2-256
      hmac-sha2-512
      hmac-md5
      hmac-md5-96
      hmac-ripemd160
      hmac-ripemd160@openssh.com
      umac-128@openssh.com
      hmac-sha1-96-etm@openssh.com
      hmac-sha2-256-etm@openssh.com
      hmac-sha2-512-etm@openssh.com
      hmac-md5-etm@openssh.com
      hmac-md5-96-etm@openssh.com
      hmac-ripemd160-etm@openssh.com
      umac-128-etm@openssh.com

    '';
  };

  users.users.hrestela.openssh.authorizedKeys.keys = [
     "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxx9Up0yJ/txCDtZRL7rb1qCfU5Hh81Il53OKMTF7EkTB2V915amgoHdjdTac2TisIasq9uNIpmZ8GA1mEICBa9A+enk31k/AI3DC6LwfPIOh+rdueB+acuhE8keTENEdwiwZ5KtiCELtCEidA0mPxu2n5tLPGk+u871/Coes73csHtMgLzI5nQkGZSwbjWSBcMzOjGKF9fhpoItQpZHt4kKTyZkpfKU4pvT8vNcyAPNQsQ4BXHfofl02n8qUDgZ/DeNgzBc4efuMiSFKOnUQd0cHLQVAYIjvj91WohiqblmkdarDLMZJ67x9qjhrK/epUCh/F48EKtUFPrSghW6vV henryestela@gmail.com"
  ];
}
