{
  pkgs,
  inputs,
  ...
}: {
  nixpkgs.overlays = [
    # oh god, this was a pain to debug, make an issue later
    (final: prev: let pkgs = inputs.fenix.inputs.nixpkgs.legacyPackages.${prev.stdenv.hostPlatform.system}; in (inputs.fenix.overlays.default pkgs pkgs) // {vscode-extensions = prev.vscode-extensions;})
  ];

  environment.systemPackages = with pkgs; [
    # rust needs a linker
    # by default it uses the linker provided by the c compiler in the system (gcc in this case)
    # it can be overriten (tried mold)
    # but it still requires cc because rust binaries link againt libc
    (inputs.fenix.packages.${stdenv.hostPlatform.system}.complete.withComponents [
      "cargo"
      "clippy"
      "rustfmt"
      "rust-analyzer-preview"
      "rust-src"
    ])
    gcc
    mold
    gdb
  ];
}
