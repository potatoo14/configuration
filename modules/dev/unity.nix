{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    csharp-ls
    mono
    unityhub # can't espace their electron bloat
  ];
}
