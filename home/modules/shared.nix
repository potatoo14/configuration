# hm is underwhelming tbh, it's kinda pointless, but sometimes handy
{
  config,
  sharedState,
  pkgs,
  lib,
  ...
}: let
  defVicinaeExtesions = list: let
    repoSrc = pkgs.fetchFromGitHub { # hopefully caching isn't invalidated anymore, fuck
      owner = "vicinaehq";
      repo = "extensions";
      rev = "cf30b80f619282d45b1748eb76e784a4f875bb01";
      hash = "sha256-KwNv+THKbNUey10q26NZPDMSzYTObRHaSDr81QP9CPY=";
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
      # "Obsidian/.obsidian.vimrc".source = "${helix-vim}/helix.vim";

      # "rust-docs".source = "${pkgs.rustc.doc}/share/doc/docs/html/index.html";

      # ".config/fcitx5" = {
      #   # idk if it's going to work well, more reproducibility is nice anyway (fcitx5)
      #   source = ./dotfiles/.config/fcitx5;
      #   recursive = true;
      # };
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
      gui = {
        user = "someone";
        password = "password";
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

  home.pointerCursor = {
    gtk.enable = true;
    # x11.enable = true;
    package = pkgs.qogir-icon-theme;
    name = "Qogir";
    size = 24;
  };

  gtk = {
    enable = true;

    # gtk4 was never intended to be themed (fixing evaluation warning)
    gtk4.theme = null;

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

    # font = {
    #   name = "Sans";
    #   size = 11;
    # };
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
