{
  lib,
  fetchzip,
  # makeDesktopItem,
  fetchVersion,
  stdenvNoCC,
  autoPatchelfHook,
  libXi,
  libXtst,
  libXfixes,
  libxkbfile,
  libX11,
  libXcomposite,
  libXdamage,
  libXrender,
  libXrandr,
  libxshmfence,
  xcb-util-cursor,
  xcbutilwm,
  xcbutilimage,
  xcbutilrenderutil,
  xcbutilkeysyms,
  gtk3,
  pango,
  at-spi2-atk,
  gdk-pixbuf,
  cups,
  nss,
  zlib,
  zstd,
  glib,
  libglvnd,
  libxkbcommon,
  fontconfig,
  dbus,
  nspr,
  freetype,
  libdrm,
  alsa-lib,
  mesa,
  krb5,
  wayland,
}:
stdenvNoCC.mkDerivation {
  pname = "rimsort-bin";
  version = "v1.0.30";

  src = fetchzip {
    url = "https://github.com/RimSort/RimSort/releases/download/v1.0.30/RimSort-v1.0.30-Ubuntu-24.04_x86_64.zip";
    sha256 = "1kzp2cgckz2spz8rmn5bdi6lhfqcdg4534a3vxkfp8pg227l54jn";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  autoPatchelfIgnoreMissingDeps = ["libQt6EglFsKmsGbmSupport.so.6"]; # not in nixpkgs, not bothering
  buildInputs = [
    libXi
    libXtst
    libXfixes
    libxkbfile
    libX11
    libXcomposite
    libXdamage
    libXrender
    libXrandr
    libxshmfence
    xcb-util-cursor
    xcbutilwm
    xcbutilimage
    xcbutilrenderutil
    xcbutilkeysyms
    gtk3
    pango
    at-spi2-atk
    gdk-pixbuf
    cups
    nss
    zlib
    zstd
    glib
    libglvnd
    libxkbcommon
    fontconfig
    dbus
    nspr
    freetype
    libdrm
    alsa-lib
    mesa
    krb5
    wayland
  ];

  # desktopItems = [
  #   (makeDesktopItem {
  #     name = "RimSort";
  #     exec = meta.mainProgram;
  #     icon = "RimSort";
  #     desktopName = "RimSort";
  #     comment = meta.description;
  #     categories = ["Game" "Utility"];
  #   })
  # ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/opt/rimsort $out/bin
    cp -r $src/* $out/opt/rimsort
    install -Dm644 "$src/themes/default-icons/AppIcon_a.png" "$out/share/icons/hicolor/512x512/apps/RimSort.png"
    ln -s $out/opt/rimsort/RimSort $out/bin/rimsort
    runHook postInstall
  '';

  meta = with lib; {
    description = "An open-source RimWorld mod manager";
    homepage = "https://github.com/RimSort/RimSort";
    license = licenses.gpl3Only;
    mainProgram = "rimsort";
  };
}
