# smartphone mic on the pc for discord
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    mumble
    qpwgraph
    vesktop
  ];
  services.murmur = {
    enable = true;
    openFirewall = true;
    bandwidth = 999999;
  };
}
