{pkgs ? import <nixpkgs> {}}: let
  osu-lazer-bin = pkgs.callPackage ./package.nix {};
in {
  # expose the package so the updater script can find it
  inherit osu-lazer-bin;

  # expose a shell for conviniently launching the game without rebuilding the system
  # nix-shell -A launcher
  launcher = pkgs.mkShellNoCC {
    packages = [osu-lazer-bin];
    shellHook = ''
      ${pkgs.mangohud}/bin/mangohud --dlsym \
      ${pkgs.gamemode}/bin/gamemoderun \
      ${osu-lazer-bin.meta.mainProgram}
    '';
  };
}
