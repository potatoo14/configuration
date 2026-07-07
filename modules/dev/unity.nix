{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    unityhub # can't espace their electron bloat
    jetbrains.rider # also can't escape their ide bloat, c# is just poorly designed to run on anything that isn't visual studio or rider
  ];
}
