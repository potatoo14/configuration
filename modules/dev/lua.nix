{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    emmylua-ls
    emmylua-check
  ];
}
