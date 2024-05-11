# Temporary setup for installation on a Kingfast SSD, Ryzen host.

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    <nixos-hardware/common/cpu/amd/pstate.nix>
    <nixos-hardware/common/pc/ssd>
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "ARISU"; # Define your hostname.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;
  };
  hardware.pulseaudio.enable = false;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.a2 = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      firefox
      tree
      samba
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    openssh
    sing-box
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    substituters = [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
    ];
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  nix.optimise.automatic = true;
  nix.extraOptions = ''
    min-free = ${toString (1024 * 1024 * 1024)}
    max-free = ${toString (2048 * 1024 * 1024)}
  '';

  # VIA USB/SATA TRIM
  services.udev.extraRules = ''
    ACTION=="add|change", ATTRS{idVendor}=="2109", ATTRS{idProduct}=="0715", SUBSYSTEM=="scsi_disk", ATTR{provisioning_mode}="unmap"
  '';

  hardware.enableAllFirmware = true;

  fileSystems."/".options = [
    "nodiscard"
    "compress=zstd"
  ];
  swapDevices = [ { device = "/dev/disk/by-uuid/7398edc0-ae0c-42d9-a078-2ac3a7b5acae"; } ];

  zramSwap.enable = true;

  security.sudo.wheelNeedsPassword = false;

  boot.kernel.sysctl = {
    "kernel.sysrq" = 1;
  };
  boot.kernelModules = [
    "nct6775"
    "zenpower"
  ];
  boot.blacklistedKernelModules = [ "k10temp" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.zenpower ];
  # boot.kernelParams = [ "" ];

  i18n.inputMethod = {
    enabled = "ibus";
    ibus.engines = with pkgs.ibus-engines; [ rime ];
  };

  # copied some of cyrolitia's stuff
  fonts = {
    packages = with pkgs; [
      sarasa-gothic
      # (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
      source-han-serif
      noto-fonts-emoji
      ubuntu_font_family
    ];

    fontconfig = {
      defaultFonts = {
        emoji = [
          "JetBrainsMono Nerd Font"
          "Noto Color Emoji"
        ];
        monospace = [
          "Sarasa Mono SC"
          "JetBrainsMono Nerd Font Mono"
        ];
        sansSerif = [ "Ubuntu" "Sarasa Gothic SC" ];
        serif = [ "Source Han Serif SC" ];
      };
    };
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}
