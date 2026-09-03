{
  nixpkgs,
  inputs,
  home-manager,
  extraArgs,
  modules,
  hm-modules,
}:
nixpkgs.lib.nixosSystem {
  specialArgs = {
    inherit inputs;
    inherit extraArgs;
  };
  modules =
    [
      home-manager.nixosModules.home-manager
      {
        home-manager = {
          users.${extraArgs.username} = {
            imports = hm-modules;
          };
          extraSpecialArgs = {
            inherit extraArgs;
          };
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "hm-bak";
        };
      }
    ]
    ++ modules;
}
