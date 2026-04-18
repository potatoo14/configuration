# so i don't need to rebuild the system after an update
{
  pkgs ?
    import <nixpkgs> {
      # overlays = [(import ../../overlay.nix)];
    },
}: let
  osu-lazer-bin = pkgs.callPackage ./default.nix {
    # fetchsrc = pkgs.fetchsrc;
    # fetchVersion = pkgs.fetchVersion;
  };
in
  pkgs.mkShellNoCC {
    packages = [osu-lazer-bin];
    shellHook = "${pkgs.mangohud}/bin/mangohud --dlsym ${pkgs.gamemode}/bin/gamemoderun ${osu-lazer-bin.meta.mainProgram}";
  }
