{
  pkgs,
  pkgs-stable,
  ...
}: {
  imports = [./hardware-configuration.nix];

  # this overlay will only be applied for pc
  nixpkgs.overlays = [
    (final: prev: {
      # so btop can see nvidia gpu
      btop = prev.btop.override {cudaSupport = true;};
    })
  ];

  # i2c for ddcutil
  hardware.i2c.enable = true;

  networking = {
    hostName = "pc";
    wireless.enable = false; # Enables wireless support via wpa_supplicant.
    # networkmanager.enable = lib.mkForce false;
  };

  # roccat udev rules, so it can acess hardware
  services.udev.packages = [pkgs-stable.roccat-tools];

  # services.flatpak.enable = true;

  hardware.bluetooth.enable = true;
  # systemd.services.bluetooth.wantedBy = lib.mkForce [];

  programs = {
    gamemode.settings.gpu = {
      apply_gpu_optimisations = "accept-responsibility";
      gpu_device = 0;
      nv_powermizer_mode = 1; # GPUPowerMizerMode Maximum Performance
      # i don't remember the sweet spot
      # nv_core_clock_mhz_offset = 100;
      # nv_mem_clock_mhz_offset = 200;
    };
  };

  environment.systemPackages = with pkgs;
    [
      #-terminal-#
      btrbk
      ntfs3g
      ddcutil
      ddcui
      android-tools
      # distrobox
      # flatpak-builder

      # libclang
      # gdtoolkit_4
      # basedpyright
      # pylyzer
      # ruff

      #-apps-#
      anki-bin
      transmission_4-gtk
      mpv # with yt-dlp
      mpvScripts.mpris
      universal-android-debloater
      # aseprite
      # prismlauncher
      # chromium
    ]
    ++ [pkgs-stable.roccat-tools];

  # Open ports in the firewall.
  # for transmission, but isp locks down router, unfortuanely >:(
  networking.firewall = {
    allowedTCPPorts = [53250];
    allowedUDPPorts = [53250];
  };

  # automatic backups
  # services.btrbk = {
  #   niceness = 10;
  #   instances.hd = {
  #     onCalendar = "daily";
  #     settings = {
  #       # nix creates a btrbk user,
  #       # so it has problems with permissions
  #       # transaction_log = "/var/log/btrbk.log";
  #       # lockfile = "/run/lock/btrbk.lock";
  #       stream_buffer = "256m";
  #       snapshot_create = "onchange";
  #       snapshot_preserve_min = "latest";
  #       target_preserve = "0h 10d 5w 6m 0y";
  #       target_preserve_min = "latest";
  #       volume."/mnt/ssd" = {
  #         target = "/mnt/hd/system_backup";
  #         subvolume = "home/user";
  #       };
  #     };
  #   };
  # };

  # btrbk is erroring out because it's trying to run b4 the hd is mounted
  # systemd.services.btrbk-hd.unitConfig.RequiresMountsFor = "/mnt/ssd /mnt/hd/system_backup";

  systemd.services.windows-sync = {
    script = ''
      ${pkgs.rsync}/bin/rsync -av /home/user/.config/keepassxc/file.kdbx /mnt/windows/Users/user/Documents/
      ${pkgs.rsync}/bin/rsync -av --delete /home/user/Archive/wallpapers/_favorites/ /mnt/windows/Users/user/Pictures/walls/

      ${pkgs.rsync}/bin/rsync -av --delete --exclude='*cache*' --exclude='*/Microsoft*/' --exclude='*/Windows*/' --exclude='*/NVIDIA*/' --exclude='*/Mozilla*/' --filter='- /Local/Temp' /mnt/windows/Users/user/AppData/ /home/user/Archive/windows-backup/AppData
      ${pkgs.rsync}/bin/rsync -av --delete --filter='- /file.kdbx' /mnt/windows/Users/user/Documents/ /home/user/Archive/windows-backup/Documents/

      ${pkgs.rsync}/bin/rsync -av --delete --filter='- /nodedist' '/mnt/windows-hd/Pirate/HITMAN - World of Assassination/Peacock' /home/user/Archive/windows-backup/hitman
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "user";
    };
  };
  systemd.timers.windows-sync = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "daily";
      Unit = "windows-sync.service";
    };
  };
}
