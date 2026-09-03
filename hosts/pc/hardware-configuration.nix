{
  lib,
  config,
  modulesPath,
  ...
}: {

  boot = {
    loader = {
      systemd-boot.enable = true;
      systemd-boot.consoleMode = "max";
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };
  };

  hardware.bluetooth.enable = true;

  # make that crusty old gpu work properly (i hope)
  # idk what this actually does
  # hardware.amdgpu.legacySupport.enable = true;

  # Load nvidia driver for Xorg and Wayland, fuck
  # https://forums.developer.nvidia.com/t/non-existent-shared-vram-on-nvidia-linux-drivers/260304/12
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false; # suspend is kinda broken anyway

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false; # doesn't work on my gpu

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = false; # useless on wayland

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    # 580 will be the last version for my gpu
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
  };

  # boot.initrd.availableKernelModules = [ "xhci_pci" "usbhid" ];
  # boot.initrd.kernelModules = [ ];
  # boot.kernelModules = [ "kvm-intel" ];
  # boot.extraModulePackages = [ ];
  # boot.kernelParams = ["intel_iommu=on"];
  # boot.kernelParams = ["nvidia.NVreg_PreserveVideoMemoryAllocations=1"]; # make suspend work

  # don't know if i use compression or not
  # it can be faster than without if io bandwith is low enough
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/027c018f-f392-4c28-a2ff-91446b169155";
    fsType = "btrfs";
    options = ["subvol=root" "noatime" "compress=zstd:3"];
  };

  fileSystems."/home/user" = {
    device = "/dev/disk/by-uuid/027c018f-f392-4c28-a2ff-91446b169155";
    fsType = "btrfs";
    options = ["subvol=user" "noatime" "compress=zstd:3"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/07AA-9649";
    fsType = "vfat";
    options = ["fmask=0137" "dmask=0027" "noatime"];
  };

  # swapDevices = [ ];

  # btrfs handles trim differenly, it's redundant to use fstrim
  # but the esp will no be trimmed, so leave it on anyway
  # https://forum.endeavouros.com/t/fstrim-timer-or-discard-async-on-btrfs-ssd-root-partition-only/59022/5
  services.fstrim.enable = false;

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkForce true;
  # networking.interfaces.enp0s31f6.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;

  # this enables config.hardware.enableRedistributableFirmware
  # basically equivalent to linux-firmware on arch
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
