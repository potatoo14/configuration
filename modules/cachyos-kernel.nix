{
  pkgs,
  inputs,
  ...
}: {
  nixpkgs.overlays = [inputs.nix-cachyos-kernel.overlays.pinned];
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3;

  # just to make sure
  nix.settings.substituters = ["https://attic.xuyh0120.win/lantian"];
  nix.settings.trusted-public-keys = ["lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="];
}
