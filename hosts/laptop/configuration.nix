{
  pkgs,
  lib,
  ...
}: {
  imports = [./hardware-configuration.nix];

  networking = {
    hostName = "laptop";
    networkmanager = {
      enable = true;
      # dns = "none"; fuck dns settings of my university wifi
      # https://discourse.nixos.org/t/networkmanager-plugins-installed-by-default/39682
      plugins = lib.mkForce [];
    };
  };

  services.tlp = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    ntfs3g
    brightnessctl
    godot
  ];
}
