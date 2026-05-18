# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  sharedState,
  inputs,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  nix.settings = {
    # lazy-trees = true;
    experimental-features = ["nix-command" "flakes"];
    trusted-users = ["root" "@wheel"];
    # it's anoying, only add, when useful:
    # --option extra-substituters http://192.168.18.4:5000
    # --option extra-trusted-public-keys local-1://mjrvGM94DuOP9onF4jbICyLmt5RqfFpra+ciY2vsg=
    # extra-substituters = [
    #   "http://192.168.18.4:5000"
    # ];
    # extra-trusted-public-keys = [
    #   "local-1://mjrvGM94DuOP9onF4jbICyLmt5RqfFpra+ciY2vsg="
    # ];
  };

  nixpkgs.config.allowUnfree = true;
  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"]; # for nixd

  # for syncthing
  networking.firewall.allowedTCPPorts = [22000];
  networking.firewall.allowedUDPPorts = [21027 22000];

  # https://astrid.tech/2022/11/03/0/overlay-nixpkgs-pr/
  # it conflicts with the nixpkgs options, idk how lib.mkForce would be used here
  # imports = ["${inputs.nixpkgs-grub-fix}/nixos/modules/system/boot/loader/grub/grub.nix"];

  nixpkgs.overlays = [
    (import ./overlay.nix)
    # oh god, this was a pain to debug, make an issue later
    (final: prev: let pkgs = inputs.fenix.inputs.nixpkgs.legacyPackages.${prev.stdenv.hostPlatform.system}; in (inputs.fenix.overlays.default pkgs pkgs) // {vscode-extensions = prev.vscode-extensions;})
  ];

  services.getty.autologinUser = sharedState.username;

  users = {
    users.${sharedState.username} = {
      isNormalUser = true;
      group = sharedState.username;
      extraGroups = sharedState.extraGroups;
      initialPassword = "changeme"; # nice to have
    };
    groups = {
      ${sharedState.username}.gid = 1000; # add a group "user" to keep compatibility with arch
      roccat = {}; # roccat group, for udev rules
    };
  };

  systemd.coredump.extraConfig = "Storage=none\nProcessSizeMax=0";
  services.journald.extraConfig = "SystemMaxUse=100M";

  # dbus broker is faster and more efficient, it's the default on arch and fedora
  services.dbus.implementation = "broker";

  # appending to the default inputrc file
  environment.etc."inputrc".text = ''
    ${builtins.readFile (modulesPath + "/programs/bash/inputrc")}
    set completion-ignore-case On
  '';

  # could use zram-generator, but i am using this instead
  zramSwap = {
    enable = true;
    memoryPercent = 75;
  };

  networking = {
    dhcpcd = {
      enable = true; # networkmanager pulls webkit for whatever reason, openresolvconf is enabled by default

      # better networking performance for free and doesn't override my dns settings
      # extraConfig = "noarp\nnohook resolv.conf";
      extraConfig = "noarp"; # my uni wifi fucks up dns so bad, i have to use what they provide
    };

    resolvconf.extraConfig = "name_server_blacklist=192.168.*.*"; # blacklist router's dns server
    nameservers = ["9.9.9.9" "149.112.112.112" "2620:fe::fe" "2620:fe::9"]; # quad9

    # https://github.com/NixOS/nixpkgs/commit/a3ccb7f562a93826ad0112adf20dc7f697b7713e
    # someone added networkmanager as a dependency for steam, it sucks
  };

  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    noto-fonts-cjk-sans # japanese fonts look horrible otherwise
  ];

  # i finally figure out how to remove this shit
  # it's enabled by default even if nix option search says it's not
  services.speechd.enable = lib.mkForce false;

  # xdg-open only work on some terminals that are hardcoded into the spec
  # this enables a spec that works for any terminal
  xdg.terminal-exec.enable = true;

  programs = {
    nh = {
      enable = true;
      flake = "/home/${sharedState.username}/nixos";
    };
  };

  environment.systemPackages = with pkgs; [
    #-terminal-#
    # quickemu
    bash-completion
    helix
    foot
    yazi
    ripdrag
    nix-tree
    btop
    fastfetch
    onefetch
    ncdu
    # trash-cli # trash is borked on btrfs subvolumes
    fd
    python3
    jq
    usbutils # for lsusb
    yt-dlp
    rsync
    file
    wev
    libnotify
    mediainfo
    ffmpeg
    nix-index

    #-language-utils-#
    git
    gh
    nixd
    alejandra
    # nixpkgs-fmt
    bash-language-server
    shfmt
    vscode-langservers-extracted
    taplo
    prettier
    basedpyright
    ruff
    delta
  ];

  # automatic garbage collection
  programs.nh.clean = {
    enable = true;
    extraArgs = "--keep-since 7d";
    dates = "daily";
  };

  # save space by hardlinking identical files
  nix.optimise = {
    automatic = true;
    dates = ["daily"];
  };

  # running on unstable, it's actually not a good idea to run auto updates
  # manual intervention might occasionally be necessary
  # system.autoUpgrade = {
  #   enable = true;
  #   flake = "/home/user/nixos";
  #   flags = [
  #     "-L" # print build logs
  #     "--recreate-lock-file" # i think this works
  #   ];
  #   operation = "boot";
  #   dates = "sat";
  #   randomizedDelaySec = "1h";
  # };
}
