{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix.url = "github:nix-community/fenix/monthly";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
  };

  outputs = {
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    system-builder = import ./utils/system-builder.nix;
  in {
    nixosConfigurations = {
      pc = system-builder {
        inherit nixpkgs;
        inherit inputs;
        inherit home-manager;
        extraArgs = {
          username = "user";
          extraGroups = [
            "wheel"
            "gamemode"
            "adbusers"
            "i2c"
            "rtkit"
          ];
        };
        modules = [
          ./hosts/pc/configuration.nix
          ./modules/cachyos-kernel.nix
          ./modules/base.nix
          ./modules/desktop.nix
          ./modules/gaming.nix
          ./modules/rust.nix
          ./modules/voice-call.nix
          ./modules/binary-cache.nix
        ];
        hm-modules = [
          ./home/hosts/pc/host.nix
          ./home/modules/base.nix
        ];
      };
      laptop = system-builder {
        inherit nixpkgs;
        inherit inputs;
        inherit home-manager;
        extraArgs = {
          username = "potato";
          extraGroups = [
            "wheel"
            "gamemode"
            "rtkit"
          ];
        };
        modules = [
          ./hosts/laptop/configuration.nix
          ./modules/base.nix
          ./modules/desktop.nix
          ./modules/gaming.nix
          ./modules/c-family.nix
        ];
        hm-modules = [
          ./home/hosts/laptop/host.nix
          ./home/modules/base.nix
        ];
      };
    };
  };
}
