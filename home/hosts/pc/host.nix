{
  config,
  lib,
  ...
}: let
  linkLocalDotfiles = files:
    lib.genAttrs files
    (path: {source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home/hosts/pc/${baseNameOf path}";});
in {
  home.file = linkLocalDotfiles [
    ".cargo/config.toml"
    ".config/hypr/bin/volume.sh"
    ".config/hypr/bin/brightness.sh"
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
