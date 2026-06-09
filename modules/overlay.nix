final: prev: {

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
}
