{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # rust needs a linker
    # by default it uses the linker provided by the c compiler in the system (gcc in this case)
    # it can be overriten (tried mold)
    # but it still requires cc because rust binaries link againt libc
    (inputs.fenix.packages.${stdenv.hostPlatform.system}.complete.withComponents [
      "cargo"
      "clippy"
      "rust-src"
      "rustc-codegen-cranelift-preview"
      "rustfmt"
      "rust-analyzer-preview"
    ])
    gcc
    mold
    gdb
  ];
}
