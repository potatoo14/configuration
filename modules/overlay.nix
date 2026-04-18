# overriding pkgs inside overlays
# these are being built from source, why not just enable cpu specific optimizations
# if this thing worked..
final: prev: let
  # pkgs = import inputs.nixpkgs {
  #   localSystem = {
  #     gcc.arch = "skylake"; # native is impure (not allowed)
  #     gcc.tune = "skylake"; # native is impure (not allowed)
  #     system = "x86_64-linux";
  #   };
  #   modules = [inputs.chaotic.nixosModules.nyx-overlay];
  # };
in {
  # i tought the mold linker was working
  # until i realized that hyprland uses it by default on it's derivation
  # final.stdenv = pkgs.stdenvAdapters.useMoldLinker prev.stdenv;

  # inherit (inputs.nixpkgs-grub-fix.legacyPackages.${prev.system}) grub;

  # osu-lazer-bin = final.callPackage ./pkgs/osu-lazer-bin/osu-lazer-bin.nix {};
  # rimsort-bin = final.callPackage ./pkgs/rimsort-bin/rimsort-bin.nix {};

  # wofi = prev.wofi.overrideAttrs (oldAttrs: {
  #   version = "hg";
  #   src = fetchsrc ./wofi.json;
  # });

  # fetching a pr in form of a patch from github to fix bug
  # i don't even use the language module anymore, using fcitx5 instead
  # waybar = prev.waybar.overrideAttrs (oldAttrs: {
  #   patches = [
  #     (pkgs.fetchurl {
  #       url = "https://patch-diff.githubusercontent.com/raw/Alexays/Waybar/pull/4068.patch";
  #       hash = "sha256-/fIvFeiB3UFPrSdhv2anJjgJcLc3M3bWkwjBrvrYp2k=";
  #     })
  #   ];
  # });

  # it's not working properly for whatever reason, like it's building and shit, but it doesn't work
  # qt6Packages = prev.qt6Packages.overrideScope (selfx: prevx: {
  #   qt6ct = prevx.qt6ct.overrideAttrs (oldAttrs: {
  #     patches = [
  #       (final.fetchpatch {
  #         url = "https://aur.archlinux.org/cgit/aur.git/plain/qt6ct-shenanigans.patch?h=qt6ct-kde";
  #         hash = "sha256-odCe+7fPnIQtOrPqYAS15rm+wsedy6zjwnieUZSfxp0=";
  #       })
  #     ];
  #   });
  # });

  # "fix" shitty udev rules check issue, doesn't work anymore
  # https://github.com/NixOS/nixpkgs/issues/410087
  # roccat-tools-fix = pkgs.callPackage ({
  #   pkgs,
  #   stdenvNoCC,
  # }:
  #   stdenvNoCC.mkDerivation {
  #     pname = "roccat-tools-fix";
  #     src = pkgs.roccat-tools;
  #     version = "1.0";
  #     nativeBuildInputs = with pkgs; [rsync];
  #     dontPatch = true;
  #     dontConfigure = true;
  #     dontBuild = true;
  #     installPhase = ''
  #       runHook preInstall
  #       mkdir -p $out
  #       rsync -a --exclude='lib/udev/rules.d/90-roccat-kone*.rules' --exclude='share/applications/*.desktop' $src/ $out/
  #       cp $src/share/applications/roccatsavuconfig.desktop $out/share/applications/
  #       runHook postInstall
  #     '';
  #   }) {};

  # deleting everything that's not for roccat savu (my mouse)
  # it would be better if these files were not built in the first place, whatever
  roccat-tools = prev.roccat-tools.overrideAttrs (oldAttrs: {
    postFixup = ''
      find $out/share/applications -type f ! -name '*savu*' -delete
      find $out/bin -type f ! -name '*savu*' -delete
      find $out/lib -type f ! -name '*savu*' ! -name 'libroccat*' -delete
    '';
  });

  # recompiling software just to fix a bug
  android-file-transfer = prev.android-file-transfer.overrideAttrs (oldAttrs: {
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [final.wrapGAppsHook3];
    buildInputs = oldAttrs.buildInputs ++ [final.gsettings-desktop-schemas];
  });

  # because ignis is a flake, can't patch the source the way i did with hyprland below
  # maybe because the flake already add an overlay, idk
  # it doesn't really work
  # the src points to the ignis derivation, which is already built
  # but python is a interpreted language, so you can patch the code anyway
  # but the executable still points to the old derivation
  # fuck
  # ignis = pkgs.applyPatches {
  #   name = "ignis"; # what name is used for?
  #   src = inputs.ignis.packages.${pkgs.stdenv.hostPlatform.system}.ignis;
  #   patches = [./pkgs/ignis/no-logfile.patch];
  # };
  # ignis = inputs.ignis.packages.${pkgs.stdenv.hostPlatform.system}.ignis;

  # bug fixed
  # hyprland = prev.hyprland.overrideAttrs (oldAttrs: {
  #   mesonBuildType = "release"; # still builds in debug mode, good enough i guess
  #   cmakeBuildType = "release";
  #   # hyprctl is saying this is a debug build, but it feels like it's not
  #   # hyprland's memory usage seems back to normal
  #   patches = [./pkgs/hyprland/fix-shadow-corner.patch];
  # });
}
