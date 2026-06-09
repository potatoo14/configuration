{pkgs ? import <nixpkgs> {}}:
with pkgs;
(buildFHSEnv {
  name = "react native devtools my ass";
  targetPkgs = pkgs: (with pkgs; [
    glib
    nspr
    nss
    dbus
    at-spi2-atk
    cups
    cairo
    gtk3
    pango
    libx11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libgbm
    expat
    libxcb
    libxkbcommon
    udev
    alsa-lib
  ]);
  runScript = "npx expo start";
  LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;
}).env
