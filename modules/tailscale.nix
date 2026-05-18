{
  pkgs,
  lib,
}: {
  systemd.services.tailscaled.wantedBy = lib.mkForce [];
  services.tailscale.enable = true;
  environment.systemPackages = with pkgs; [tailscale];
}
