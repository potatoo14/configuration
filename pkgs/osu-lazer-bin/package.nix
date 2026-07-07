{
  lib,
  fetchurl,
  appimageTools,
  makeWrapper,
  nativeWayland ? true,
}: let
  pname = "osu-lazer-bin";
  version = "2026.624.0";

  src = fetchurl {
    url = "https://github.com/ppy/osu/releases/download/${version}-lazer/osu.AppImage";
    hash = "sha256-EKmCq656djPGK5I1JqSDcTKtpbQZbO8WGWcPv+PT0q4=";
  };

  meta = {
    description = "Rhythm is just a *click* away (AppImage version for score submission and multiplayer, and binary distribution for Darwin systems)";
    homepage = "https://osu.ppy.sh";
    license = with lib.licenses; [
      mit
      cc-by-nc-40
      unfreeRedistributable # osu-framework contains libbass.so in repository
    ];
    sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    maintainers = with lib.maintainers; [
      gepbird
      stepbrobd
      Guanran928
    ];
    mainProgram = "osu!";
    platforms = [
      "x86_64-linux"
    ];
  };

  passthru.updateScript = ./update.sh;
in
  appimageTools.wrapType2 {
    inherit
      pname
      version
      src
      meta
      passthru
      ;

    extraPkgs = pkgs: with pkgs; [icu];

    # fix OpenGL renderer on nvidia + wayland
    extraBwrapArgs = [
      "--ro-bind-try /etc/egl/egl_external_platform.d /etc/egl/egl_external_platform.d"
    ];

    extraInstallCommands = let
      contents = appimageTools.extract {inherit pname version src;};
    in ''
      . ${makeWrapper}/nix-support/setup-hook
      mv -v $out/bin/${pname} $out/bin/osu!

      wrapProgram $out/bin/osu! \
        ${lib.optionalString nativeWayland "--set SDL_VIDEODRIVER wayland"} \
        --set OSU_EXTERNAL_UPDATE_PROVIDER 1

      install -m 444 -D ${contents}/osu!.desktop -t $out/share/applications
      for i in 16 32 48 64 96 128 256 512 1024; do
        install -D ${contents}/osu.png $out/share/icons/hicolor/''${i}x$i/apps/osu.png
      done
    '';
  }
