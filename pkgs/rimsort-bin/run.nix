# i use rimsort very rarely, so...
{
  pkgs ?
    import <nixpkgs> {
      # overlays = [(import ../../overlay.nix)];
    },
}: let
  rimsort-bin = pkgs.callPackage ./default.nix {};
in
  pkgs.mkShellNoCC {
    packages = [rimsort-bin];
    shellHook = "${rimsort-bin.meta.mainProgram}";
  }
