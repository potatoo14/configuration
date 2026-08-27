{
  pkgs,
  extraArgs,
  ...
}: {
  services.nix-serve = {
    enable = true;
    package = pkgs.nix-serve-ng;
    secretKeyFile = "/home/${extraArgs.username}/.config/nix/secret.key";
    openFirewall = true;
  };
}
