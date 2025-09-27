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
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

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
    # If you want to use JACK applications, uncomment thisin
  };
  services.pulseaudio.enable = false;

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (subject.isInGroup("wheel"))
        return polkit.Result.YES;
    });
  '';

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.a2 = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs;
      [
        audacious
        firefox
        virtualbox
        gimp
        qq
        fontforge
        inkscape
      ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages =
    with pkgs;
    [
      vim
      wget
      openssh
      sing-box
      nur.repos.cryolitia.rime-project-trans
      nur.repos.linyinfeng.rimePackages.rime-ice
      busybox
      btop
      compsize
      gparted
      ntfs3g
      apfsprogs
      tree
      samba
      vscode
      git
      htop
      oxipng
      pngquant
      python3
      apfs-fuse
    ]
    ++ (with pkgs; [
      gcc
      gnumake
      libarchive
      bash
      zstd
      xz
    ])
    ++ (with pkgs.python313Packages; [
      numpy
      matplotlib
      pillow
      cycler
      kiwisolver
      packaging
      pip
      pyparsing
      python-dateutil
    ]);

  # ++ lib.attrsets.attrValues (
  #    builtins.removeAttrs pkgs.pkgsx86_64_v3-core [
  #      "recurseForDerivations"
  #      "_description"
  #    ]
  #  );

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
  services.avahi = {
    nssmdns4 = true;
    enable = true;
    ipv4 = true;
    ipv6 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
  nix.settings = {
    substituters = [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store?priority=30"
      "https://mirrors.ustc.edu.cn/nix-channels/store?priority=30"
      "https://chaotic-nyx.cachix.org"
    ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    system-features = lib.mkForce [
      "gccarch-x86-64-v3"
      "benchmark"
      "big-parallel"
      "kvm"
      "nixos-test"
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
    max-substitution-jobs = 32
  '';

  # VIA USB/SATA TRIM
  services.udev.extraRules = ''
    ACTION=="add|change", ATTRS{idVendor}=="2109", ATTRS{idProduct}=="0715", SUBSYSTEM=="scsi_disk", ATTR{provisioning_mode}="unmap"
  '';

  hardware.enableAllFirmware = true;

  zramSwap.enable = true;

  security.sudo.wheelNeedsPassword = false;

  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
  boot.kernel.sysctl = {
    "kernel.sysrq" = 1;
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.tcp_ecn" = 2;
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_notsent_lowat" = 131072;
    "net.ipv4.tcp_mtu_probing" = 1;
  };
  boot.kernelModules = [
    "nct6775"
    "zenpower"
    "virtualbox"
    "apfs"
  ];
  boot.blacklistedKernelModules = [ "k10temp" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ apfs zenpower ];
  boot.kernelParams = [
    "zswap.enabled=1"
    "zswap.compressor=zstd"
    "zswap.max_pool_percent=40"
    "zswap.shrinker_enabled=1"
    "damon_reclaim.enabled=1"
  ];

  i18n.inputMethod = {
    type = "ibus";
    enable = true;
    ibus.engines = with pkgs.ibus-engines; [ rime ];
  };

  fonts = {
    # copied some of cyrolitia's stuff
    packages = with pkgs; [
      sarasa-gothic
      # (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
      source-han-serif
      noto-fonts-emoji
      ubuntu_font_family
      gyre-fonts
      libertinus
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
        sansSerif = [
          "Ubuntu"
          "Sarasa Gothic SC"
        ];
        serif = [
          "TeX Gyre Pagella"
          "Source Han Serif SC"
        ];
      };
      localConf = ''
        <!-- Linux Libertine &rarr; Libertinus -->
        <match target="pattern">
          <test qual="any" name="family"><string>Linux Libertine</string></test>
          <edit name="family" mode="assign" binding="same"><string>Libertinus Serif</string></edit>
        </match>
      '';
      subpixel.rgba = "rgb";
      hinting.style = "medium";
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
