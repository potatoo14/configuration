{
  pkgs,
  sharedState,
  ...
}: {
  services.nix-serve = {
    enable = true;
    package = pkgs.nix-serve-ng;
    secretKeyFile = "/home/${sharedState.username}/.config/nix/secret.key";
    openFirewall = true;
  };
}
