# hm is underwhelming tbh, it's kinda pointless, but sometimes handy
{
  config,
  sharedState,
  pkgs,
  lib,
  ...
}: let
  defVicinaeExtesions = list: let
    repoSrc = pkgs.fetchFromGitHub {
      # hopefully caching isn't invalidated anymore, fuck
      owner = "vicinaehq";
      repo = "extensions";
      rev = "afb84fe4b5253777ff82db8e19e6cc0c9b7f811f";
      hash = "sha256-Non+frT3WG0TN60zCq63m8+d7yNmCCMaI363kZaDmPM=";
    };
  in
    map (name:
      config.lib.vicinae.mkExtension {
        name = name;
        src = "${repoSrc}/extensions/${name}";
      })
    list;
  defYaziPlugins = plugins: lib.genAttrs plugins (plugin: pkgs.yaziPlugins."${plugin}");
  # i forgot to say that mkOutOfStoreSymlink behaves different with flakes because this whole repo is copied to the store before being evaluated, so the symlinks point to the store instead of this repo, misleading name, i know (i don't remeber the github links)
  linkDotfiles = files:
    lib.genAttrs files
    (path: {source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home/dotfiles/${path}";});
in {
  home = {
    homeDirectory = "/home/${sharedState.username}";
    username = sharedState.username;
  };
  # treating this like gnu stow
  home.file =
    {
      # for hyprland.lua autocompletion (because of how nix doesn't follow FHS)
      "nixos/.emmyrc.json".text = builtins.toJSON {
        workspace = {
          library = ["${pkgs.hyprland}/share/hypr/stubs"];
        };
      };
    }
    // linkDotfiles [
      ".bashrc"
      ".bash_profile"
      ".config/fastfetch/config.jsonc"
      ".config/foot"
      ".config/git/config"
      ".config/helix"
      ".config/hypr/hyprland.lua"
      ".config/hypr/bin/screenshot.sh"
      ".config/hypr/bin/shader.py"
      ".config/hypr/bin/wallupdater.sh"
      ".config/MangoHud/MangoHud.conf"
      ".config/mpv/mpv.conf"
      ".config/pipewire/pipewire.conf"
      ".config/swaync"
      ".config/vicinae"
      ".config/waybar/uptime.py"
      ".config/waybar/style.css"
      ".config/waybar/config.jsonc"
      ".config/yazi/init.lua"
      ".config/yazi/keymap.toml"
      ".config/yazi/theme.toml"
      ".config/yazi/yazi.toml"
      ".config/dxvk.conf"
    ];

  services.syncthing = {
    enable = true;
    settings = {
      options = {
        # globalAnnounceEnabled = false;
        # relaysEnabled = false;
        urAccepted = -1;
      };
      devices = {
        "pc" = {id = "D57DRWT-RN6SG2H-4MRX4I5-VU4P3AF-IFTDBA5-ERNV2XD-LU3NMYU-TIYBSAA";};
        "laptop" = {id = "FVVYBWX-4SHRCJO-ZBUMK53-FYW2P5V-VV2BBUW-HKLN7CI-7ZNU3NA-HNKPAQV";};
        "phone" = {id = "GFA35HI-Z7P7FDK-7WL2SZB-BYYQF4N-WBP34QR-GMHMBIY-4ZDQWSG-7LSUGQN";};
      };
      folders = let
        devices = ["phone" "pc" "laptop"];
      in {
        "${config.home.homeDirectory}/Obsidian" = {
          id = "Obsidian";
          inherit devices;
        };
        "${config.home.homeDirectory}/.config/keepassxc/kdbx" = {
          id = "keepass";
          inherit devices;
        };
        "${config.home.homeDirectory}/Archive" = {
          id = "Archive";
          inherit devices;
        };
        "${config.home.homeDirectory}/Repos/Shared" = {
          id = "Shared Repos";
          inherit devices;
        };
        "${config.home.homeDirectory}/nixos" = {
          id = "nixos";
          inherit devices;
        };
        "/mnt/hd/stuff/syncthing" = {
          id = "anime sync";
          devices = ["phone" "pc"];
        };
      };
    };
  };

  programs = {
    vicinae = {
      enable = true;
      extensions = defVicinaeExtesions [
        "nix"
        "firefox"
      ];
    };

    yazi = {
      enable = true;
      plugins = defYaziPlugins [
        "full-border"
        "toggle-pane"
      ];
    };
  };

  home.pointerCursor = let
    name = "miku-cursor";
  in {
    enable = true;
    gtk.enable = true;
    size = 24;
    inherit name;
    package = pkgs.runCommand name {} ''
      mkdir -p $out/share/icons
      ln -s ${pkgs.fetchzip {
        url = "https://github.com/supermariofps/hatsune-miku-windows-linux-cursors/releases/download/1.2.6/miku-cursor-linux.tar.xz";
        sha256 = "sha256-qxWhzTDzjMxK7NWzpMV9EMuF5rg9gnO8AZlc1J8CRjY=";
      }} $out/share/icons/${name};
    '';
  };

  gtk = {
    enable = true;

    gtk4.theme = config.gtk.theme; # theming is hard

    theme = {
      package = pkgs.catppuccin-gtk.override {
        accents = ["teal"];
        variant = "mocha";
      };
      name = "catppuccin-mocha-teal-standard";
    };

    iconTheme = {
      package = pkgs.qogir-icon-theme;
      name = "Qogir";
    };
  };

  # i still have to open the gui and configure stuff manually,
  # this just set an env var, and adds some packages
  qt = {
    enable = true;
    platformTheme.name = "qtct"; # it doesn't work aparently, maybe environment.d isn't applied
  };

  dconf.settings = {
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "";
      audible-bell = false;
    };
    "org/gnome/desktop/sound" = {
      event-sounds = false;
      input-feedback-sounds = false;
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
}
