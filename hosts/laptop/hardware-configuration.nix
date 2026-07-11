{
  config,
  lib,
  modulesPath,
  ...
}: {
  boot = {
    loader = {
      timeout = 0;
      grub = {
        enable = true;
        efiSupport = true;
        timeoutStyle = "hidden";
        useOSProber = true;
        devices = ["nodev"];
        default = 3;
      };
    };

    initrd.availableKernelModules = ["xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "sr_mod" "rtsx_usb_sdmmc"];
    # initrd.kernelModules = [];
    # kernelModules = [];
    # extraModulePackages = [];
  };

  hardware.bluetooth.enable = true;
  # systemd.services.bluetooth.wantedBy = lib.mkForce []; # didn't work

  time.hardwareClockInLocalTime = true;

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/884534c9-c2d9-469b-83af-ad048582ac3e";
    fsType = "btrfs";
    options = ["subvol=root" "noatime" "compress=zstd:2"];
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/712A-4F5E";
    fsType = "vfat";
    options = ["fmask=0137" "dmask=0027" "noatime"];
  };
  fileSystems."/home/potato" = {
    device = "/dev/disk/by-uuid/884534c9-c2d9-469b-83af-ad048582ac3e";
    fsType = "btrfs";
    options = ["subvol=home/potato" "noatime" "compress=zstd:2"];
  };
  fileSystems."/mnt/hd" = {
    device = "/dev/disk/by-uuid/f1df8be9-db64-49f4-a430-b54600d39e46";
    fsType = "btrfs";
    options = ["subvol=Stuff" "noatime" "nofail" "x-systemd.device-timeout=10" "compress=zstd:3"];
  };
  fileSystems."/home/potato/Archive" = {
    device = "/dev/disk/by-uuid/f1df8be9-db64-49f4-a430-b54600d39e46";
    fsType = "btrfs";
    options = ["subvol=Archive" "noatime" "nofail" "x-systemd.device-timeout=10" "compress=zstd:3"];
  };

  swapDevices = [];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp9s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp7s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?
}
