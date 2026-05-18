{
  lib,
}: {
  systemd.services.sshd.wantedBy = lib.mkForce [];
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      UseDns = true;
      # X11Forwarding = true;
    };
  };
}
