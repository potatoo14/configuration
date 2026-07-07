{
  lib,
  fetchzip,
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
stdenvNoCC.mkDerivation rec {
  pname = "rimsort-bin";
  version = "v1.4.2";

  src = fetchzip {
    url = "https://github.com/RimSort/RimSort/releases/download/${version}/RimSort-${version}-Ubuntu-24.04_x86_64.tar.gz";
    sha256 = "sha256-s503GIo4xyI1NwGal0PeoHlC3mQjlwY/4jLWIZhEZp0=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  # technically kdePackages.qtbase, but not bothering
  # there's also libtiff, which requires an onder version of the lib
  autoPatchelfIgnoreMissingDeps = ["libQt6EglFsKmsGbmSupport.so.6" "libtiff.so.5"];
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
