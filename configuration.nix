{
  config,
  pkgs,
  username,
  host,
  lib,
  ...
}:
{

  imports = [
    ./hardware-configuration.nix
  ];

  # ===== Boot Configuration =====
  #boot.loader.systemd-boot.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.supportedFilesystems = [ "ntfs" ];

  #! Enable grub below, note you will have to change to the new bios boot option for settings to apply
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
      };
    };
  };

  # ===== Hardware Configuration =====
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  # ===== Filesystems =====
  # USER EDITABLE ADD FILESYSTEMS HERE
  fileSystems."/mnt/Seagate Expansion Drive" =
  { device = "/dev/sda2";
    fsType = "ntfs-3g"; 
    options = [ "rw" "uid=1000"];
  };

  # ===== Security =====
  security = {
    polkit.enable = true;
    sudo = {
      enable = true;
      extraRules = [
        {
          commands = [
            {
              command = "${pkgs.systemd}/bin/reboot";
              options = [ "NOPASSWD" ];
            }
            {
              command = "${pkgs.systemd}/bin/poweroff";
              options = [ "NOPASSWD" ];
            }
            {
              command = "${pkgs.systemd}/bin/shutdown";
              options = [ "NOPASSWD" ];
            }
          ];
          groups = [ "wheel" ];
        }
      ];
    };
  };
  # ===== System Services =====
  services.udisks2.enable = true;

  # Virt-manager
  #virtualisation.libvirtd = {
  #  enable = true;
  #  qemu = {
  #    package = pkgs.qemu_kvm;
  #    runAsRoot = true;
  #    swtpm.enable = true;
  #    ovmf = {
  #      enable = true;
  #    };
  #  };
  #};

  # Plex
  services.plex = {
    enable = true;
    openFirewall = true;
  };

  # Syncthing
  services = {
    syncthing = {
        enable = true;
        user = "x";
        dataDir = "/home/x/Documents";    # Default folder for new synced folders
        configDir = "/home/x/Documents/.config/syncthing";   # Folder for Syncthing's settings and keys
      };
  };
  
  services = {
    libinput.enable = true;
    spice-vdagentd.enable = true;
    qemuGuest.enable = true;
    blueman.enable = true;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      wireplumber.enable = true;
    };
    dbus.enable = true;
    xserver = {
      enable = false;
      videoDrivers = [ "amdgpu" ];
    };
    openssh.enable = true;
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
        settings = {
          autoLogin.enable = true;
          autoLogin.user = username;
          AutoLogin = {
            User = username;
            Session = "hyprland.desktop";
          };
        };
        theme = "catppuccin-mocha";
        package = pkgs.kdePackages.sddm;
      };
      sessionPackages = [ pkgs.hyprland ];
    };
  };

  networking = {
    hostName = host;
    networkmanager.enable = true;
  };
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      # SSH
      22
      # Pipewire
      4713
    ];
    allowedUDPPorts = [
      # Pipewire
      4713
      # DHCP
      68
      546
    ];
  };

  # ===== System Configuration =====
  time.timeZone = "America/Merida";
  i18n.defaultLocale = "en_US.UTF-8";

  # ===== User Configuration =====
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "libvirtd"
      "networkmanager"
      "video"
    ];
  };
  users.defaultUserShell = pkgs.zsh;

  # ===== Nix Configuration =====
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [ "https://cache.nixos.org" ];
    trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
    extra-substituters = [
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # ===== System Packages =====
  environment.systemPackages = with pkgs; [
    # My Apps
    alarm-clock-applet
    android-studio
    android-studio-tools
    anydesk
    btop
    chromium
    discord
    distrobox
    electron
    element-desktop
    enpass
    fastfetch
    firefoxpwa
    flac
    flutter
    fsearch
    gh
    git
    glib
    gnome-disk-utility
    htop
    hypnotix
    kate
    kdePackages.gwenview
    kdePackages.kdeconnect-kde
    kdePackages.konsole
    kid3
    kitty
    libsForQt5.filelight
    localsend
    looking-glass-client
    mediainfo
    mediainfo-gui
    mlocate
    mkvtoolnix
    neofetch
    nicotine-plus
    nodejs_18
    ntfs3g
    obsidian
    onlyoffice-bin_latest
    pipx
    plex
    plex-media-player
    pnpm
    podman
    python3
    python311Packages.deemix
    python311Packages.pip
    python311Packages.pypresence
    pywal
    pywalfox-native
    qbittorrent
    rclone
    rssguard
    rsync
    soulseekqt
    sox
    subtitleedit
    syncthing
    tauon
    telegram-desktop
    thunderbird
    uget
    vscode
    yt-dlp

    # KVM/QEMU
    bridge-utils
    dnsmasq
    ebtables
    libguestfs
    netcat-openbsd
    qemu
    qemu_full
    vde2
    virt-manager
    libvirt-glib
    OVMF
    swtpm

    # Core Packages
    lld
    gcc
    glibc
    clang
    udev
    llvmPackages.bintools
    wget
    procps
    killall
    zip
    unzip
    bluez
    busybox
    bluez-tools
    brightnessctl
    light
    xdg-utils
    pipewire
    wireplumber
    alsaLib
    pkg-config
    #kdePackages.qtsvg
    libsForQt5.qtsvg # for svg thumbnails
    usbutils
    lxqt.lxqt-policykit
    home-manager
    mesa

    # sddm
    kdePackages.sddm
    (catppuccin-sddm.override { flavor = "mocha"; })

    # Standard Packages
    networkmanager
    networkmanagerapplet
    git
    fzf
    tldr
    sox
    yad
    flatpak
    ffmpeg

    # GTK Packages
    gtk2
    gtk3
    gtk4
    tela-circle-icon-theme
    bibata-cursors

    # QT Packages
    qtcreator
    qt5.qtwayland
    qt6.qtwayland
    qt6.qmake
    libsForQt5.qt5.qtwayland
    qt5ct
    gsettings-qt

    # Xorg Libraries
    xorg.libX11
    xorg.libXcursor

    # Other Hyprdots dependencies
    hyprland
    waybar
    xwayland
    cliphist
    alacritty
    swww
    swaynotificationcenter
    lxde.lxsession
    gtklock
    eww
    xdg-desktop-portal-hyprland
    where-is-my-sddm-theme
    firefox
    pavucontrol
    blueman
    trash-cli
    ydotool
    lsd
    parallel
    pwvucontrol
    pamixer
    udiskie
    dunst
    swaylock-effects
    wlogout
    hyprpicker
    slurp
    swappy
    polkit_gnome
    libinput-gestures
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    jq
    #kdePackages.qtimageformats
    libsForQt5.qtimageformats # for dolphin image thumbnails
    #kdePackages.ffmpegthumbs
    libsForQt5.ffmpegthumbs # for dolphin video thumbnails
    #kdePackages.kde-cli-tools
    libsForQt5.kde-cli-tools # for dolphin file type defaults
    libnotify
    libsForQt5.qt5.qtquickcontrols
    libsForQt5.qt5.qtquickcontrols2
    libsForQt5.qt5.qtgraphicaleffects
    libsForQt5.qt5ct
    libsForQt5.qtstyleplugin-kvantum
    kdePackages.qtstyleplugin-kvantum
    kdePackages.qt6ct
    #kdePackages.wayland
    libsForQt5.qtwayland # for wayland support
    rofi-wayland
    nwg-look
    ark
    #dolphin
    libsForQt5.dolphin # kde file manager
    libsForQt5.kdegraphics-thumbnailers # for dolphin video thumbnails
    libsForQt5.kimageformats # for dolphin image thumbnails
    libsForQt5.kio # for fuse support
    libsForQt5.kio-extras # for extra protocol support
    libsForQt5.kwayland # for wayland support
    resvg # for svg thumbnails
    kitty
    eza
    oh-my-zsh
    zsh
    zsh-powerlevel10k
    envsubst
    hyprcursor
    imagemagick
    gnumake
    tree
    papirus-icon-theme
    wofi
    vscode
    openssh
    vim
    git
    gnumake
    cachix
    wl-clipboard
    grim
    grimblast
  ];

  # ===== Program Configurations =====
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
  ];

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    nativeMessagingHosts.packages = [ pkgs.firefoxpwa ];
  };

  programs.kdeconnect.enable = true;

  programs = {
    git.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      ohMyZsh = {
        enable = true;
        plugins = [
          "git"
          "history"
          "sudo"
        ];
      };
      promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    };
   
  };

  # ===== Font Configuration =====
  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-emoji
      noto-fonts-cjk
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
      noto-fonts-color-emoji
      material-icons
      font-awesome
      atkinson-hyperlegible
    ];
  };

  # ===== Environment Configuration =====
  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1";
    shellInit = ''
      if [ -d $HOME/.nix-profile/share/applications ]; then
        XDG_DATA_DIRS="$HOME/.nix-profile/share:$XDG_DATA_DIRS"
      fi
    '';

  };

  # ===== System Version =====
  system.stateVersion = "24.11"; # Don't change this
}
