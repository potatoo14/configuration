{
  pkgs,
  lib,
  ...
}: {
  # fuck https://github.com/NixOS/nixpkgs/issues/264815
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc-ut
      fcitx5-gtk
      qt6Packages.fcitx5-configtool
      catppuccin-fcitx5
    ];
  };

  # hint electron apps to use wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # xdg-desktop-portal (non hyprland) pulls flatpak for whatever reason, so much bloat
  # trying to remove some bloat, but it removes the hyprland portal too
  # xdg.portal.enable = lib.mkForce false;

  # this commit https://github.com/NixOS/nixpkgs/commit/9020d82c70759706968b39571c71103a1347f073
  # pulling xdg-desktop-portal-gtk without reason to, more bloat i guess
  # https://wiki.hyprland.org/Hypr-Ecosystem/xdg-desktop-portal-hyprland/
  # XDPH doesn’t implement a file picker, it recommends the gtk portal alongside XDPH
  xdg.portal.extraPortals = lib.mkForce [pkgs.xdg-desktop-portal-hyprland];

  programs = {
    hyprland = {
      enable = true;
      systemd.setPath.enable = true; # fix xdg-open
      withUWSM = true;
    };
    # firefox-bin dosen't integrate as well with system but it's better optimized than the hydra build
    firefox = {
      package = pkgs.firefox-bin;
      enable = true;
      preferences = {
        "browser.compactmode.show" = true;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true; # https://github.com/djc/no-close-buttons
        "extensions.webextensions.restrictedDomains" = ""; # and enable on restricted pages for dark reader
      };
    };
  };

  # pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };

  environment.systemPackages = with pkgs; [
    waybar
    swaybg
    grim
    slurp
    playerctl
    hyprpicker
    wl-clipboard
    wev
    wl-gammactl
    swaynotificationcenter
    mesa-demos # i like to have glxinfo
    # pandoc # markdown to odt converter

    keepassxc
    qalculate-gtk
    pavucontrol
    easyeffects
    (android-file-transfer.overrideAttrs (oldAttrs: {
      nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [pkgs.wrapGAppsHook3];
      buildInputs = oldAttrs.buildInputs ++ [pkgs.gsettings-desktop-schemas];
    }))
    # dconf-editor
    # rnote
    # gparted
  ]; # ++ [pkgs-stable.libreoffice];
}
