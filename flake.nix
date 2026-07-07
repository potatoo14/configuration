{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fenix.url = "github:nix-community/fenix/monthly";

    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-stable,
    home-manager,
    fenix,
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
            pkgs-stable = import nixpkgs-stable {
              system = "x86_64-linux";
              overlays = [(import ./modules/overlay.nix)];
            };
          };
          modules = [
            ./hosts/pc/configuration.nix
            ./modules/shared.nix
            ./modules/desktop.nix
            ./modules/gaming.nix
            ./modules/dev/c-family.nix
            ./modules/dev/rust.nix
            ./modules/dev/android-expo.nix
            ./modules/voice-call.nix
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
            pkgs-stable = import nixpkgs-stable {
              system = "x86_64-linux";
              overlays = [(import ./modules/overlay.nix)];
            };
          };
          modules = [
            ./hosts/laptop/configuration.nix
            ./modules/shared.nix
            ./modules/desktop.nix
            ./modules/dev/rust.nix
            ./modules/dev/android-expo.nix
            ./modules/mongo.nix

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
