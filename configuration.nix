# We left it at looking into the terminal-exec stuff.

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
# MediaKeys for volume control don't work, but brightness control keys do.
# WiFi might be interfering with the bluetooth audio channel because they likely
# use the same hardware card, but do look into the issue of random stuttering.
# The fontconfig seems not to be working on Firefox.
# Set up home-manager for managing home directory configs like i3; don't
# configure them just yet.
# Set up Firefox as a second-in-command browser for media consumption (uBo is a
# better ad-blocker than qutebrowser's.)

{ config, lib, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Qt configuration required for plugins on some packages to work.
  qt = {
    enable = true;
    platformTheme = "gtk2";
    style = "gtk2";
  };

  # XDG configuration.
  xdg = {
    # Desktop portal settings.
    portal = {
      enable = true;

      # All-out GTK-styled integration.
      config = { common = { default = [ "gtk" ]; }; };
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

      # Hopefully solves the manpage-listed bugs before they even happen.
      xdgOpenUsePortal = true;
    };

    # To open terminal programs (ranger) into e.g. file picker windows.
    terminal-exec = {
      enable = true;

      # Look up how correct it is setting this to wezterm.desktop.
      settings = { "none+i3" = [ "wezterm.desktop" ];
                   default = [ "wezterm.desktop" ]; };
    };
  };

  programs = {
    # AppImage support.
    appimage = {
      enable = true;

      # Seamlessly run AppImage's through binfmt registration.
      binfmt = true;
    };

    # Mount filesystems without requiring a user password.
    udevil.enable = true;

    # Enable a CUPS external GUI to the WebUI.
    system-config-printer.enable = true;

    # Zsh shell configuration.
    zsh = {
      enable = true;

      # Preserve current directory across terminals.
      vteIntegration = true;

      syntaxHighlighting = {
        enable = true;
        # Consider setting this up by following the corresponding manpage links.
      };

      autosuggestions = {
        enable = true;

	# Quick note: the 'zpty' module mentioned in the manpage already comes
	# packaged with zsh post release 3.1.
        strategy = [ "history" "completion" ];
      };

      # Enable really helpful framework around zsh.
      ohMyZsh = {
        enable = true;
        # Consider configuring the rest of the available OhMyZsh options.
      };
    };

    # VCS.
    git = {
      enable = true;

      # Consider setting this config up.
      config = [ ];

      # Research into it.
      prompt.enable = false;
    };

    # System monitoring.
    atop = {
      enable = true;

      # Daily timer for rotated results.
      atopRotateTimer.enable = true;

      # Required for root-level operations.
      setuidWrapper.enable = true;

      # The following two ensure in-depth, long-term analysis.
      atopService.enable = true;
      atopacctService.enable = true;
    };

    # Simple command prompt.
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

    # Text/Code editor.
    neovim = {
      enable = true;

      # Neovim basic config; if plugins are wished for, check manpage.
      configure.customRC = ''
	                   set number
	                   set colorcolumn=81
                           set clipboard+=unnamedplus
	                   '';

      # Set EDITOR="nvim" to avoid setting it in the ENV variables.
      defaultEditor = true;

      # Set 'nvim' to alias 'vi'.
      viAlias = true;
    };

    # This is a, UI-wise, richer alternative to 'ping'.
    mtr.enable = true;
  };

  # Environment configuration; shell, ENV variables and system packages.
  environment = {
    # Set zsh as only allowed user account shell.
    shells = [ pkgs.zsh ];

    shellAliases = {
      # Useful outside a display server without a date indicator.
      d = "date";
    };

    # Declarative, user-independent ENV variables.
    variables = {
      # Compliments the EDITOR environment variable set in
      # programs.neovim.defaultEditor.
      VISUAL = "nvim";
    };

    # Package management. To search for available packages, run:
    # $ nix-env -qaP wget
    systemPackages = with pkgs; [
      rclone
      wget
      w3m
      tree
      dosfstools
      pavucontrol
      wezterm
      gh
      qbittorrent
      xclip
      qutebrowser

      # Required for program.<name>.enable to work.
      iay

      # Required for checking if hardware acceleration is running.
      clinfo vulkan-tools libva-utils
    ];
  };

  # Sound management.
  sound = {
    enable = true;
    mediaKeys.enable = true;
  };

  # Networking management.
  networking = {
    # Set up a hosts blocklist to avoid brain damage.
    stevenblack = {
      enable = true;
      block = [ "fakenews" "gambling" "porn" "social" ];
    };

    # Define your hostname; the domain is already set by DHCPCD.
    hostName = "dope";

    # Easy networking configuration.
    networkmanager.enable = true;

    # Enforce security by disabling downgrades to WPA2 on networks mixing
    # WPA2/WPA3 for compatibility.
    wireless.fallbackToWPA2 = false;

    # Disable firewall.
    firewall.enable = false;
  };

  # Font management; defaults and packages.
  fonts = {
    # Enable some (hopefully good) unicode coverage.
    enableDefaultPackages = true;
    enableGhostscriptFonts = true;

    fontconfig = {
      # Set up monospaced power.
      defaultFonts = {
        monospace = [ "JetBrains Mono Bold" ];
        sansSerif = [ "JetBrains Mono Bold" ];
        serif = [ "JetBrains Mono Bold" ];
      };

      # Enforce declarativeness by disabling user config files.
      includeUserConf = false;

      # Default used by most monitors.
      subpixel.rgba = "rgb";
    };

    packages = [ pkgs.jetbrains-mono ];
  };

  # User settings management.
  users = {
    # Enforce declarativeness.
    mutableUsers = false;

    # Set default shell for all users to zsh; it's the only one enabled but
    # /bin/sh is active by default so it's worth setting everything to zsh.
    defaultUserShell = pkgs.zsh;

    # Configure main user.
    users.adam = {
      # Automatically add the user to 'users' group, create a home directory,
      # and use the default set user shell.
      isNormalUser = true;

      # 'video' group required for hardware.acpilight.enable brightness control.
      extraGroups = [ "wheel" "video" "networkmanager" ];

      # Dumb, but it works on a local level (my level).
      password = "me";
    };
  };

  services = {
    # Uptime monitoring.
    tuptime.enable = true;

    # Battery management.
    upower.enable = true;

    # Enable blueman as a Bluetooth manager.
    blueman.enable = true;

    # Set the timezone automatically.
    automatic-timezoned.enable = true;

    # Enable autologin in ttys.
    getty.autologinUser = "adam";

    # Display manager and sddm management.
    displayManager = {
      # Might be a tad bit ambiguous because of sddm.enable following, but it's
      # false by default.
      enable = true;

      # Enable autologin just because.
      autoLogin = {
        enable = true;
        user = "adam";
      };

      # Enable sddm over NixOS' default lightdm.
      sddm = {
        enable = true;

        # Enables autologin even when you just logged out but didn't reboot.
        autoLogin.relogin = true;
      };

      # Set the default session to only consider a window manager.
      defaultSession = "none+i3";
    };

    # X11 server management.
    xserver = {
      enable = true;

      # Because we use i3, XDG autostart isn't run by default.
      desktopManager.runXdgAutostartIfNone = true;

      # Use i3wm; for configuring it, look into the manpage.
      windowManager.i3.enable = true;

      # Set a few useful commands; look into getting shift + caps to enable all
      # caps or simply look into the syntax (not in the manpage).
      xkb.options = "eurosign:e,caps:escape";
    };

    # Configure mouse and touchpad in X11.
    libinput = {
      touchpad.disableWhileTyping = true;

      mouse = {
        disableWhileTyping = true;

        # Avoid transforming a simultaneous left and right click into a middle
	# mouse button click.
        middleEmulation = false;
      };
    };

    # Hide mouse when inactive.
    unclutter-xfixes.enable = true;

    # Wallpaper eye-candy; generates a colorful wallpaper on login.
    fractalart = {
      enable = true;
      height = 1080;
      width = 1920;
    };

    # Enable printing.
    printing.enable = true; # A WebUI is served by default at localhost:631.

    # Enable Pipewire sound server.
    pipewire = {
      enable = true;

      # Enable Pipewire as the primary sound server; any of the three options
      # below will do.
      alsa.enable = true;
      jack.enable = true;
      pulse.enable = true;
    };

    # Allow greater application support by using an ALSA loopback device instead
    # of a PCM plugin.
    jack.loopback.enable = true;
  };

  # Hardware and firmware management.
  hardware = {
    # Disregard license control.
    enableAllFirmware = true;

    # Backlight control.
    acpilight.enable = true;

    # This seems to also set up bluetooth service control; look into it.
    bluetooth.enable = true;

    # Update microcode for my current CPU manufacturer.
    cpu.amd.updateMicrocode = true;

    opengl = {
      enable = true;

      # Install packages required for AMD hardware acceleration.
      extraPackages = with pkgs; [ rocmPackages.clr.icd amdvlk libva ];
    };
  };

  # Set tty console config to follow X11 keyboard options.
  console.useXkbConfig = true;

  # Location provider management.
  location.provider = "geoclue2";

  # Boot process management.
  boot = {
    loader = {
      # Use the systemd-boot EFI boot loader.
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;

      # Change scaling for best screen fit.
      systemd-boot.consoleMode = "max";

      # Disable root access through kernel parameter init=/bin/sh to enhance
      # security.
      systemd-boot.editor = false;

      # Change time for auto-booting into pre-selected boot option; "null"
      # option for no time is broken as of 05/2024.
      timeout = 20;
    };

    # Eye-candy for the boot process; hides initial boot status messages.
    plymouth.enable = true;

    # Use latest linux-zen kernel.
    kernelPackages = pkgs.linuxPackages_zen;

    # If at any point the system crashes on boot, try this.
    # hardwareScan = false;
  };

  # To automatically run
  # $ nix-store --optimise
  # and manage duplicates.
  nix.settings.auto-optimise-store = true;

  # To allow unfree package derivations.
  nixpkgs.config.allowUnfree = true;

  # To acquire real-time priority for the Pulseaudio sound server.
  security.rtkit.enable = true;

  # System management.
  system = {
    autoUpgrade = {
      enable = true;

      # If editing the config and the system updates, better finish editing it
      # or else it might load up a new gen on boot that could be broken from
      # your unfinished changes but be 'nicely' updated.
      operation = "boot";
    };

    # Copies the system config to /run/current-system/configuration.nix.
    copySystemConfiguration = true;

    stateVersion = "24.11"; # Don't touch this.
  };
}
