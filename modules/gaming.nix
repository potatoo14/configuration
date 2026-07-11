{pkgs, ...}: {
  programs = {
    # using gamemode instead of manually setting cpu governor
    gamemode = {
      enable = true;
      enableRenice = true;
      settings = {
        general = {
          softrealtime = "on";
          renice = 5;
        };
      };
    };
    steam = {
      enable = true;
      extraCompatPackages = [pkgs.dw-proton-bin];
      package = pkgs.steam.override {
        extraEnv = {
          MANGOHUD = true;
          PROTON_USE_XALIA = false; # i don't use controllers and dwproton's xalia has a high cpu usage bug
        };
      };
    };
  };
  nixpkgs.overlays = [
    (final: prev: {
      dw-proton-bin = prev.proton-ge-bin.overrideAttrs (oldAttrs: rec {
        pname = "dw-proton-bin";
        version = "dwproton-11.0-5";
        src = prev.fetchzip {
          url = "https://dawn.wine/dawn-winery/dwproton/releases/download/${version}/${version}-x86_64.tar.xz";
          hash = "sha256-2x4xotJ2aJYbg+G2TDPqyU7uuoc/hZQon9CA6SFGin0=";
        };
        preFixup = "";
      });
      prismlauncher-unwrapped = prev.prismlauncher-unwrapped.overrideAttrs (oldAttrs: rec {
        version = "9.4";
        src = final.fetchFromGitHub {
          owner = "Diegiwg";
          repo = "PrismLauncher-Cracked"; # drm-free fork
          rev = "refs/tags/${version}";
          hash = "sha256-Ld6t+zKGfDcXjfELdbcBAh9RQlAp7LIumUjQ2s7fjKg=";
        };
      });
    })
  ];
  environment.systemPackages = with pkgs; [
    mangohud
    # heroic
    # osu-lazer-bin
    # gamescope
    # (prismlauncher.override {jdks = [jdk21];})
    # innoextract # can extract gog installers without windows or wine
    # https://github.com/NixOS/nixpkgs/issues/304832
    # nobody wants to maintain rimsort, it got closed b4 merging
    # rimsort-bin
  ];
}
