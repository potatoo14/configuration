{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-old.url = "nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fenix.url = "github:nix-community/fenix/monthly";

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
  };

  outputs = {
    nixpkgs,
    nixpkgs-old,
    home-manager,
    ...
  } @ inputs: let
    globalSharedState = {
      # TODO: add some specific groups to each user
      extraGroups = [
        "wheel"
        "roccat"
        "gamemode"
        "adbusers"
        "i2c"
        "docker"
        "rtkit"
        "libvirtd"
      ];
      hm = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "hm-bak";
      };
    };
  in {
    nixosConfigurations = {
      pc = let
        sharedState =
          globalSharedState
          // {
            username = "user";
          };
      in
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            inherit sharedState;
            pkgs-old = import nixpkgs-old {
              system = "x86_64-linux";
              overlays = [(import ./modules/overlay.nix)];
            };
          };
          modules = [
            ./hosts/pc/configuration.nix
            ./modules/cachyos-kernel.nix
            ./modules/shared.nix
            ./modules/desktop.nix
            ./modules/gaming.nix
            ./modules/rust.nix
            # ./modules/voice-call.nix
            ./modules/binary-cache.nix

            # home is built with the system
            home-manager.nixosModules.home-manager
            {
              # this is a set that just happens to be on the modules list, wtf
              home-manager =
                {
                  users.user = {
                    imports = [
                      ./home/hosts/pc/host.nix
                      ./home/modules/shared.nix
                      ./home/modules/wallupdater.nix
                    ];
                  };
                  extraSpecialArgs = {
                    inherit sharedState;
                  };
                }
                // sharedState.hm;
            }
          ];
        };
      laptop = let
        sharedState =
          globalSharedState
          // {
            username = "potato";
          };
      in
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            inherit sharedState;
          };
          modules = [
            ./hosts/laptop/configuration.nix
            ./modules/cachyos-kernel.nix
            ./modules/shared.nix
            ./modules/desktop.nix
            ./modules/rust.nix

            home-manager.nixosModules.home-manager
            {
              home-manager =
                {
                  users.potato = {
                    imports = [
                      ./home/hosts/laptop/host.nix
                      ./home/modules/shared.nix
                      ./home/modules/wallupdater.nix
                    ];
                  };
                  extraSpecialArgs = {
                    inherit sharedState;
                  };
                }
                // sharedState.hm;
            }
          ];
        };
    };
  };
}
