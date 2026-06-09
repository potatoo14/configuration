{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    gcc
    mold
    gdb
    clang-tools
  ];
}
