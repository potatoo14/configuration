{pkgs, ...}: {
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
    wireless.enable = false;
  };

  programs = {
    gamemode.settings.gpu = {
      apply_gpu_optimisations = "accept-responsibility";
      gpu_device = 0;
      nv_powermizer_mode = 1; # GPUPowerMizerMode Maximum Performance
      # i don't remember the sweet spot
      # nv_core_clock_mhz_offset = 100;
      # nv_mem_clock_mhz_offset = 200;
    };
    ydotool.enable = true;
  };

  environment.systemPackages = with pkgs; [
    #-terminal-#
    btrbk
    ntfs3g
    ddcutil
    ddcui
    android-tools
    ydotool

    #-apps-#
    anki-bin
    transmission_4-gtk
    mpv # with yt-dlp
    mpvScripts.mpris
    universal-android-debloater
    azahar
  ];

  # Open ports in the firewall.
  # for transmission, but isp locks down router, unfortuanely >:(
  networking.firewall = {
    allowedTCPPorts = [53250];
    allowedUDPPorts = [53250];
  };
}
