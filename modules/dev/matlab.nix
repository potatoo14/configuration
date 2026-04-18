{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    matlab-language-server
    octaveFull
  ];
}
