# Todo list:
# - mediaKeys for volume control don't work; they're wrongly set by actkbd so
#   instead of activating them through the mediaKeys.enable setting, you set
#   actkbd.bindings with the same implementation as the one in source but the
#   keys changed, seeing as that's the only thing that happens when
#   sound.mediaKeys are enabled; it could be the issue is with the parallel
#   keybindings that i3wm sets up in its ~/.config/i3/config file.
# - WiFi might be interfering with the bluetooth audio channel because they
#   likely use the same hardware card, but do look into the issue of random
#   stuttering; in KDE there are no issues with the Internet, and the Bluettoh
#   can be fixed by restarting the bluetooth service after connecting the
#   device.
# - Look into lesspager's error output.
# - Look into man xorg.conf for configuring xserver options; there are some that
#   are repeated from the xorg.conf file in specific NixOS parameters, so
#   careful not to set them up twice.
# - Set up zathura for PDF viewing.
# - Set up home-manager for managing home directory configs like i3; don't
#   configure them just yet.
# - i3wm has already had its font changed and the horizontal and vertical split
#   keybinds disabled; add to that enabling tabbed view as default.
# - Set up config in multiple files; divide each major setting below in files;
#   get rid of ambiguous comments.
# - Set up services.unclutter to support hiding the mouse during scroll events.
{ config, lib, pkgs, ... }:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];
  # Qt configuration required for plugins on some packages to work.
  qt = {
    enable = true;

    # All-out GTK2 customization.
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
      # Hopefully solves the bugs mentioned in the manpage.
      xdgOpenUsePortal = true;
    };
    # To open terminal programs (ranger) into e.g. file picker windows.
    terminal-exec = {
      enable = true;
      # Set terminal to be used for both $XDG_CURRENT_DESKTOP and the default
      # fallback.
      settings = {
        "none+i3" = [ "org.wezfurlong.wezterm.desktop" ];
        default = [ "org.wezfurlong.wezterm.desktop" ];
      };
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
    # Desktop-independent, vt-integrated backlight control.
    light = {
      enable = true;
      # Enable keyboard keys to change backlight control.
      brightnessKeys.enable = true;
    };
    # Enable a CUPS external GUI to the WebUI.
    system-config-printer.enable = true;
    # Zsh shell configuration.
    zsh = {
      enable = true;
      # Preserve current directory across terminals.
      vteIntegration = true;
      syntaxHighlighting = {
        enable = true;
        # Enable all highlighters.
        highlighters = [
	  "main"
	  "brackets" # Matches brackets and parenthesis.
          "pattern" # Matches user-defined patterns.
	  "regexp" # Matches user-defined regular expressions.
	  "cursor" # Matches the cursor position.
          "root" # Highlights the whole command-line when root.
          "line" # Applied to the whole command line.
        ];
      };
      autosuggestions = {
        enable = true;
	# Quick note: the 'zpty' module mentioned in the manpage already comes
	# packaged with zsh post release 3.1.
        strategy = [ "history" "completion" ];
      };
      # Enable ohMyZsh.
      ohMyZsh = {
        enable = true;
        plugins = [
	  "copypath" # Copy absolute current directory path.
	  "aliases" # Provide a list of configured aliases for commands.
          "colored-man-pages" # Colorize manpages.
	  "colorize" # Colorize 'ccat' (not cat) output syntax.
	  "gitignore" # Provide direct .gitignore template downloads; to use:
	              # gi [TEMPLATENAME] >> .gitignore
	  "git" # Provide useful git aliases; the most useful to us:
	        # - gaa; git add --all
	        # - gwip; temp wip commit and a few other useful things
	        # - gcmsg; git commit -m
	        # - gd; git diff
	        # - gf; git fetch
	        # - glgga; git log with a nice graph
	        # - gprom; git pull rebase origin master
	        # - gp; git push
	        # - gpsup; git push --set-upstream origin master
	        # - gst; git status
        ];
      };
    };
    # VCS.
    git.enable = true;
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
    # Simple command prompt; needs to be included in systemPackages because the
    # source implementation doesn't include it by default.
    iay = {
      enable = true;
      minimalPrompt = true;
    };
    # Less pager command; works in tty even though default value is false.
    less.enable = true;
    # Text/Code editor.
    neovim = {
      enable = true;
      # Neovim basic config; if plugins are wished for, check manpage.
      configure.customRC = ''
        set number
        set colorcolumn=81
        set clipboard+=unnamedplus
	set ignorecase
	set smartcase
      '';
      # Set EDITOR="nvim" to avoid setting the ENV variable.
      defaultEditor = true;
      # Set 'nvim' to alias 'vi' and 'vim'.
      viAlias = true;
      vimAlias = true;
    };
    # This is a, UI-wise, richer alternative to 'ping'.
    mtr.enable = true;
  };
  # Environment configuration; shell, ENV variables and system packages.
  environment = {
    # Set zsh as the only allowed user account shell.
    shells = [ pkgs.zsh ];
    shellAliases = {
      # Useful outside a display server without a date indicator.
      d = "date";
      # Quick system administration.
      sc = "sudoedit /etc/nixos/configuration.nix";
      sb = "sudo nixos-rebuild boot";
      c = ''
        cd /home/adam/nixos-config && \
        cp /etc/nixos/configuration.nix . && gwip && gp && cd -
      '';
      cs = ''
        cd /home/adam/nixos-config && cp /etc/nixos/configuration.nix . && \
        gst && cd -
      '';
      cgd = "cd /home/adam/nixos-config && gd && cd -";
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
      kcc
      rar
      mcomix
      rclone
      python3
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
      # Required for 'colorize' ohMyZsh plugin to work.
      chroma
      # Required for program.<name>.enable to work.
      iay udevil
      # Required for checking if hardware acceleration is running.
      clinfo vulkan-tools libva-utils
    ];
  };
  # Sound management; mediaKeys left for manual config with services.actkbd.
  sound = {
    enable = true;
    mediaKeys.volumeStep = "10%";
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
    # Instead of using the systemPackages option, use this specific setting.
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
      # 'video' group needed for programs.light to grant user access.
      extraGroups = [ "wheel" "video" "networkmanager" ];
      # Dumb, but it works on a local level (my current level).
      password = "me";
    };
  };
  services = {
    # Enable udisks2 daemon for udevil wrapper; programs.udevil.
    udisks2 = {
      enable = true;
      # Mount on /media instead of the default location /run/media/$USER.
      mountOnMedia = true;
    };
    # Enable actkbd bindings for sound.mediaKeys; though don't enable the
    # mediaKeys themselves, only the implementation in
    # services/audio/alsa.nix with the fixed keycodes.
    actkbd = {
      # The keycodes in actkbd are not the same as the ones in pkgs.xorg.xev;
      # more info at https://wiki.nixos.org/wiki/Actkbd.
      bindings = [
        # Mute volume keycode in current keyboard.
        { keys = [ 221 ]; events = [ "key" ]; command = ''
	  amixer -q set Master toggle
	''; }
        # Lower volume keycode in current keyboard.
        { keys = [ 222 ]; events = [ "key" ]; command = ''
	  amixer -q set Master ${config.sound.mediaKeys.volumeStep}- unmute
	''; }
        # Raise volume keycode in current keyboard.
        { keys = [ 223 ]; events = [ "key" ]; command = ''
	  amixer -q set Master ${config.sound.mediaKeys.volumeStep}+ unmute
	''; }
        # Mic mute key was left unconfigured because there was none in my
        # current keyboard.
      ];
    };
    # Notification daemon.
    systembus-notify.enable = true;
    # Set the timezone automatically.
    automatic-timezoned.enable = true;
    # kmscon; a vt-console replacement for gettys.
    kmscon = {
      enable = true;
      # Autologin main user.
      autologinUser = "adam";
      # Enable custom font.
      fonts = [ {
        name = "JetBrains Mono Bold";
        package = pkgs.jetbrains-mono;
      } ];
      # Use hardware acceleration if supported.
      hwRender = true;
    };
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
      # Set the default session to only consider a window manager and no DE.
      defaultSession = "none+i3";
    };
    # X11 server management.
    xserver = {
      enable = true;
      # Use i3wm.
      windowManager.i3.enable = true;
      # Because we use i3, XDG autostart isn't run by default.
      desktopManager.runXdgAutostartIfNone = true;
      # Set off all screen-off events.
      serverFlagsSection = ''
        Option "BlankTime" "0"
	Option "StandbyTime" "0"
	Option "SuspendTime" "0"
	Option "OffTime" "0"
      '';
      # Set a few useful commands; caps goes to escape and shitf + caps to caps
      # lock.
      xkb.options = "eurosign:e,caps:escape_shifted_capslock";
    };
    # Configure picom compositor.
    picom = {
      enable = true;
      # This solves X11's screen tearing issues.
      vSync = true;
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
    # Wallpaper eye-candy; generates a colorful wallpaper on log in.
    fractalart = {
      enable = true;
      height = 1080;
      width = 1920;
    };
    # Enable printing.
    printing = {
      # A WebUI is served by default at localhost:631.
      enable = true;
      # This should prevent 'client-error-document-format-not-supported'.
      cups-pdf.enable = true;
    };
    # Configure the Pipewire sound server.
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
    # Set up bluetooth service control.
    bluetooth.enable = true;
    # Update microcode for my current CPU manufacturer.
    cpu.amd.updateMicrocode = true;
    # Manage hardware acceleration.
    opengl = {
      enable = true;
      # Install required packages.
      extraPackages = with pkgs; [ rocmPackages.clr.icd amdvlk libva ];
    };
  };
  # Set virtual console config.
  console = {
    # Set up console options during initrd.
    earlySetup = true;
    # Follow X11 keyboard options.
    useXkbConfig = true;
  };
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
  nix.settings = {
    # To automatically run
    # $ nix-store --optimise
    # and manage duplicates.
    auto-optimise-store = true;
    # Set max concurrent jobs for my current machine; lscpu and look for CPU(s).
    max-jobs = 4;
  };
  # To allow unfree package derivations.
  nixpkgs.config.allowUnfree = true;
  # Process-dependent security management.
  security = {
    # To acquire real-time priority for the Pulseaudio sound server.
    rtkit.enable = true;
    # Required for services.udisks2 to work.
    polkit.enable = true;
  };
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
    # Don't touch this.
    stateVersion = "24.11";
  };
}
