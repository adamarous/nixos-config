# Todo list:
# Check messages scattered throughout the config for post-config tweaking.
# Consider setting up networking.networkmanager.ensureProfiles.profiles as well
# as networking.networkmanager.settings to further enforce declarativeness.
# Research into networking.wireless options and the extent of their effect when
# using networkManager; e.g. networking.wireless.scanOnLowSignal.
# Set up nix.settings.max-jobs once you look into the specific value for it.
# Look into generating extra docs for other packages, under
# documentation.nixos.includeAllModules.
# Look into how does programs.<name>.enable syntax work along with pkgs.<name>
# for installation; some (e.g. iay) need both to work while others (e.g. git)
# seem to work simply with the former.
# See into 'sudo-rs' as a memory-safe alternative to 'sudo'.
# See into service.acpid.enable and its relationship with
# hardware.acpilight.enable.
# Consider enabling either one of service.clipcat or service.clipmenu.
# Look into the implications of enabling or disabling services.homed.
# Look into enabling kmscon and configuring it as a replacement for tty, even
# after having a display manager set up.
# See into the difference between the powerKey and the hibernateKey to configure
# different behaviours in services.logind.
# Consider researching about services.picom as a composite server for X11.
# Consider researching about the implications of enabling all three server
# emulators with PipeWire and the possible conflicts that might cause.
# Look into services.printing.cups-pdf.enable and how useful it could be for us.
# Look into how OK it is to activate services.systembus-notify.
# Look into using services.udisks2 for removable media management.
# Look into services.upower.enableWattsUpPro to see whether it's beneficial for
# us or not.
# Look into services.upower.noPollBatteries to see whether our hardware sends
# out events or we've got to poll for battery levels.
# Look into services.xfs.enable for managing X11 fonts.
# Look into how OK is it to set time.hardwareClockInLocalTime.
# Look into xdg.portal.enable and how beneficial it might be for us.
# MediaKeys for volume control don't work, but brightness control keys do.
# WiFi might be interfering with the bluetooth audio channel because they likely
# use the same hardware card, but do look into the issue of random stuttering.
# The fontconfig seems not to be working on Firefox.
# Set up home-manager for managing home directory configs like i3; don't
# configure them just yet.

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Hardware and firmware management.
  hardware = {
    enableAllFirmware = true; # Disregard license control.
    acpilight.enable = true; # Backlight control.
    bluetooth.enable = true;
    cpu.amd.updateMicrocode = true;
    opengl = {
      enable = true;
      extraPackages = with pkgs; [ rocmPackages.clr.icd amdvlk libva ];
    };
  };

  # Uptime monitoring.
  services.tuptime.enable = true;

  # Battery management.
  services.upower.enable = true;

  # Enable blueman as a Bluetooth manager.
  services.blueman.enable = true;

  # To automatically run
  # $ nix-store --optimise
  # and manage duplicates.
  nix.settings.auto-optimise-store = true;

  # AppImage support.
  programs.appimage = {
    enable = true;
    binfmt = true; # Seamlessly run AppImage's through binfmt registration.
  };

  # Mount filesystems without requiring the user password.
  programs.udevil.enable = true;

  # This is for your own good, son (or daughter); basically setup a hosts
  # blocklist to avoid brain damage.
  networking.stevenblack = {
    enable = true;
    block = [ "fakenews" "gambling" "porn" "social" ];
  };

  # Use the systemd-boot EFI boot loader and configure it.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      systemd-boot.consoleMode = "max"; # Change scaling for best screen fit.
      systemd-boot.editor = false; # Disable root access through kernel parameter
                                   # init=/bin/sh to enhance security.
      timeout = 20; # Change time for auto-booting into pre-selected boot option;
                    # "null" option for no time is broken as of 05/2024.
    };
    # Eye-candy for the boot process; hides initial status messages.
    plymouth.enable = true;
    # Check if plymouth font is any useful during boot; if so, try to shorten
    # the line length to adhere to the 80 char. limit.
    # plymouth.font = "${pkgs.jetbrains-mono}/share/fonts/truetype/JetBrainsMono-Bold.ttf";
  };

  # Use latest linux-zen kernel.
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # If at any point the system crashes on boot, try this.
  # boot.hardwareScan = false;

  # Networking management.
  networking.hostName = "dope"; # Define your hostname.
  networking.networkmanager.enable = true; # Easy networking configuration.
  networking.wireless.fallbackToWPA2 = false; # Enforce security by disabling
                                              # downgrades to WPA2 on networks
					      # mixing WPA2/WPA3 for compat.

  # Location and timezone management.
  services.automatic-timezoned.enable = true;
  location.provider = "geoclue2";

  # Set tty console config to follow X11 options and autologin.
  console.useXkbConfig = true;
  services.getty.autologinUser = "adam";

  # Display manager service and sddm management.
  services.displayManager = {
    enable = true; # Might be a tad bit ambiguous because of sddm.enable
                   # following, but it's false by default.
    sddm = {
      enable = true;
      autoLogin.relogin = true; # Enables autologin even when you just logged
                                # out but didn't reboot.
    };
    autoLogin = {
      enable = true;
      user = "adam";
    };
    defaultSession = "none+i3";
  };

  # X11 server management.
  services.xserver = {
    enable = true;
    desktopManager = {
      runXdgAutostartIfNone = true; # Because we use i3, XDG autostart isn't run
                                    # by default.
    };
    windowManager.i3.enable = true;
    xkb.options = "eurosign:e,caps:escape";

  };

  # Configure keymap, mouse and touchpad in X11.
  services = {
    libinput = {
      mouse = {
        disableWhileTyping = true;
        middleEmulation = false; # Avoid transforming a simultaneous left and
                                 # right click into a middle mouse button click.
      };
      touchpad = {
        disableWhileTyping = true;
      };
    };
  };
  # Hide mouse when inactive.
  services.unclutter-xfixes.enable = true;

  # XDG configuration.
  xdg.terminal-exec = {
    enable = true;
    settings = { default = [ "wezterm.desktop" ]; };
  };

  # Wallpaper eye-candy; generates a colorful wallpaper on login.
  services.fractalart = {
    enable = true;
    height = 1080;
    width = 1920;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true; # A WebUI is also served by default.
  programs.system-config-printer.enable = true; # External GUI.

  # Enable sound and Pipewire server.
  sound = {
    enable = true;
    mediaKeys.enable = true;
  };
  services.pipewire = {
    enable = true;
    # Enable Pipewire as the primary sound server; any of the three options
    # below will do.
    alsa.enable = true;
    jack.enable = true;
    pulse.enable = true;
  };
  # Consider enabling the following if some Pulseaudio component requires it.
  security.rtkit.enable = false;
  # Look into fine-tuning configs for the following option if it doesn't work.
  services.jack.loopback.enable = true; # Allow greater application support by
                                        # using an ALSA loopback device instead
					# of a PCM plugin.

  # Configure main user and enforce declarativeness.
  users.mutableUsers = false;
  users.users.adam = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "networkmanager" ];
    password = "me";
  };

  # Define zsh as global shell, define useful shell aliases and set global ENV
  # variables.
  environment = {
    shells = [ pkgs.zsh ];
    shellAliases = {
      d = "date";
    };
    variables = {
      VISUAL = "nvim";
    };
  };
  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    vteIntegration = true; # Preserve current directory of shell across
                           # terminals.
    syntaxHighlighting = {
      enable = true;
      # Consider setting this up by following the corresponding man page links.
    };
    autosuggestions = {
      enable = true;
      strategy = [ "history" ]; # Consider changing this to 'completion' after
                              # researching about the 'zpty' module.
    };
    ohMyZsh = {
      enable = true;
      # Consider configuring the rest of the available OhMyZsh options.
    };
  };

  # Qt configuration required for plugins on the bellow pkgs to work.
  qt = {
    enable = true;
    platformTheme = "qt5ct";
    style = "adwaita-dark";
  };

  # Package management. To search for available packages, run:
  # $ nix-env -qaP wget
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    rclone
    wget
    w3m
    tree
    dosfstools
    clinfo
    vulkan-tools
    libva-utils
    pavucontrol
    wezterm
    gh
    qbittorrent
    xclip
    # Required for program.<name>.enable to work.
    iay mouse-actions
    # Required for Qt config.
    libsForQt5.qt5ct qt6Packages.qt6ct
    adwaita-qt adwaita-qt6
  ];
  fonts.packages = [ pkgs.jetbrains-mono ];
  programs = {
    # Browser.
    firefox = {
      enable = true;
      languagePacks = [ "en-US" ];
      # Consider configuring the following:
      policies = { }; # For more ergonomical/non-niche settings and extensions.
      preferences = { }; # For changes in about:config.
    };
    # VCS.
    git = {
      enable = true;
      config = [ ]; # Consider setting this config up.
      prompt.enable = false; # Research into it.
    };
    # System monitoring.
    atop = {
      enable = true;
      atopRotateTimer.enable = true; # Daily timer for rotated results.
      setuidWrapper.enable = true; # Required for root-level operations.
      # The following two ensure in-depth, long-term analysis.
      atopService.enable = true;
      atopacctService.enable = true;
    };
    # Command prompt.
    iay = {
      enable = true;
      minimalPrompt = true;
    };
    # Less pager command; works in tty even though default value is false.
    less.enable = true;
    # Desktop-independent keyboard brightness control; even in a tty.
    light = {
      enable = true;
      brightnessKeys.enable = true;
    };
    # Corner mouse operation enabler.
    mouse-actions.enable = true;
    # Text editor.
    neovim = {
      enable = true;
      configure = {
        customRC =
	''
	set number
	set colorcolumn=81
	'';
      };
      defaultEditor = true; # Set EDITOR="nvim" to avoid setting it in the ENV
                            # variables.
      vimAlias = true; # Set 'nvim' to alias 'vi'.
    };
  };

  # Font management.
  fonts = {
    enableDefaultPackages = true;
    enableGhostscriptFonts = true;
    fontconfig = {
      defaultFonts = {
        monospace = [ "JetBrainsMono Bold" ];
        sansSerif = [ "JetBrainsMono Bold" ];
        serif = [ "JetBrainsMono Bold" ];
      };
      includeUserConf = false; # Enforce declarativeness by disabling user
                               # config files.
      subpixel.rgba = "rgb"; # Default used by most monitors.
    };
  };

  # Some programs need SUID wrappers, can be configured further or are started
  # in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Disable firewall.
  networking.firewall.enable = false;

  # System management.
  system = {
    autoUpgrade = {
      enable = true;
      operation = "boot";
    };
    copySystemConfiguration = true; # Copied to
                                    # /run/current-system/configuration.nix.
    stateVersion = "24.11"; # Don't touch this.
  };
}
