{
  config,
  lib,
  ...
}: let
  # janky, i don't think split is the right funtion for the job, anyway
  getFilename = path: builtins.elemAt (builtins.elemAt (builtins.split "([^/]+)$" path) 1) 0;
  linkLocalDotfiles = files:
    lib.genAttrs files
    (path: {source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home/hosts/pc/${getFilename path}";});
in {
  home.file = linkLocalDotfiles [
    ".config/hypr/volume.sh"
    ".config/hypr/brightness.sh"
    ".config/hypr/local.conf"
    ".config/waybar/local.jsonc"
  ];

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";
}
