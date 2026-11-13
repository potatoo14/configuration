# smartphone mic on the pc for discord
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    (pkgs.callPackage ../pkgs/mumble-pipewire-fixed.nix {})
    qpwgraph
    discord
  ];
  services.murmur = {
    enable = true;
    openFirewall = true;
    bandwidth = 999999;
  };
}
