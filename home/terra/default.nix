{ config, pkgs, ... }: let
  # check the nix wiki for 1password config:
  # https://nixos.wiki/wiki/1Password
in {
  imports = [
    ../git.nix
    ../gtk
    ../kitty.nix
    # ../lang/dotnet.nix
    ../lang/elixir.nix
    # ../lang/yaml.nix
    ../neovim
    ../shell.nix
    ../tmux
    ../waybar
  ];

  home.packages = with pkgs; [
    _1password-gui
    appimage-run
    discord
    docker
    firefox
    grimblast
    nautilus
    obs-studio
    pavucontrol
    protonup
    slack
    spotify
    udiskie
    udisks
    usbutils
    unzip
    xclip
    wget
    wl-clipboard
    wofi
    wofi-emoji
    wowup-cf
    zenity
    zoom-us
  ];

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

  services.easyeffects.enable = true;

  # k9s
  programs.k9s.enable = true;

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    matchBlocks = {
      "github.com" = {};
      "pdq" =
        {
          hostname = "192.168.86.34";
          user = "jasonnoonan";
          dynamicForwards = [{ port = 8081; }];

          localForwards = [
            # default elixir port
            {
              bind.port = 4000;
              host.address = "localhost";
              host.port = 4000;
            }

            # postgres for ash testing
            {
              bind.port = 5434;
              host.address = "localhost";
              host.port = 5434;
            }
          ];

          forwardAgent = true;
        };
    };
  };
  programs.vscode.enable = true;

  programs.zsh.shellAliases.handshake = "${pkgs.nh}/bin/nh os switch /etc/nixos";
  programs.zsh.shellAliases.helpshake = "${pkgs.nh}/bin/nh os switch --help";

  wayland.windowManager.hyprland = {
	enable = true;
	xwayland.enable = true;
	systemd.enable = true;
	settings = {
		exec-once = ["hyprctl setcursor Bibata-Modern-Ice 22"];

		env = [ "XCURSOR_SIZE,24" ];

		general = {
		  allow_tearing = true;
		  gaps_in = 2;
		  gaps_out = 6;
		  border_size = 2;
		  "col.active_border" = "rgb(F48FB1) rgb(78A8FF) 45deg";
		  "col.inactive_border" = "rgba(585272aa)";
		  layout = "dwindle";
		  resize_on_border = true;
		};

		dwindle = {
		  pseudotile = true;
		  preserve_split = true;
		};

		master = {
		  orientation = "left";
		};

		monitor = [
      "DP-3, 3440x1440@144, 0x0, 1, vrr, 1"
      "HDMI-A-1, 3840x2160@25, auto-up, 1"
		];

		decoration = {
		  rounding = 5;
		  blur = {
		    enabled = true;
		    size = 3;
		    passes = 1;
		    new_optimizations = true;
		  };
		  shadow = {
		    enabled = true;
		    range = 4;
		    render_power = 3;
		  };
		};

		group = {
		  "col.border_active" = "rgba(63F2F1aa)";
		  "col.border_inactive" = "rgba(585272aa)";

		  groupbar = {
		    font_family = "Iosevka";
		    font_size = 13;
		    "col.active" = "rgba(63F2F1aa)";
		    "col.inactive" = "rgba(585272aa)";
		  };
		};

		misc = {
		  disable_hyprland_logo = true;
		  disable_splash_rendering = true;
		  background_color = "0x1e1c31";
		};

		xwayland = {
		  force_zero_scaling = true;
		};

		input = {
		  kb_layout = "us";
		  sensitivity = 0.15;
		  follow_mouse = 1;
		  touchpad = {
		    natural_scroll = true;
		    drag_lock = true;
		  };
		};

		gestures = {
		  workspace_swipe = true;
		  workspace_swipe_distance = 200;
		  workspace_swipe_forever = true;
		};

		animations = {
		  enabled = true;
		  bezier = [
		    "overshot,0.05,0.9,0.1,1.1"
		    "overshot,0.13,0.99,0.29,1."
		  ];
		  animation = [
		    "windows,1,7,overshot,slide"
		    "border,1,10,default"
		    "fade,1,10,default"
		    "workspaces,1,7,overshot,slidevert"
		  ];
		};

		workspace = [
      "5, on-created-empty:steam"
      "special:1password, on-created-empty:1password"
      "special:idleon, on-created-empty:steam steam://rungameid/1476970"
      "special:logseq, on-created-empty:appimage-run ~/Downloads/Logseq-linux-x64-0.10.9.AppImage"
      "special:notes, on-created-empty:kitty --title='kitty-float'"
      "special:pdqssh, on-created-empty:kitty --title='kitty-ssh' ssh pdq"
      "special:zoom, on-created-empty:microsoft-edge https://app.zoom.us/wc/home --new-window"
      "special:bluetooth, on-created-empty:blueman-manager"
		];

		windowrulev2 = [
		  "workspace 2,class:kitty"
		  "workspace 1,title:^(Mozilla Firefox)(.*)$"
		  "workspace 1,class:firefox"
		  "workspace 1,class:Slack"

		  "monitor HDMI-A-1, title:OBS.*"
		  "workspace 4, title:OBS.*"

		  "monitor DP-1, class:wow\.exe"
		  "fullscreen, class:wow\.exe"
		  "workspace 5, class:wow\.exe"

      "float, title:Battle\.net"
		  "workspace 5,title:Battle\.net"

		  "float, class:steam"
		  "size 1500 1000, class:steam"
		  "workspace 5,class:steam"

		  "monitor DP-1, title:kitty-ssh"
		  "fullscreen, title:kitty-ssh"
		  "workspace special:pdqssh,title:kitty-ssh"

		  "float, class:steam_app_1476970"
		  "monitor DP-1, class:steam_app_1476970"
		  "workspace special:idleon,class:steam_app_1476970"

		  "float, class:1Password"
		  "center, class:1Password"
		  "workspace special:1password,class:1Password"

		  "float, title:kitty-float"
		  "center, title:kitty-float"
		  "size 1000 750, title:kitty-float"
		  "workspace special:notes,title:kitty-float"

		  "float, title:btop"

		  "float, class:Logseq"
		  "center, class:Logseq"
		  "size 1500 1400, class:Logseq"
		  "workspace special:logseq,class:Logseq"

		  "float, title:Bluetooth Devices"
		  "center, title:Bluetooth Devices"
		  "workspace special:bluetooth,title:Bluetooth Devices"
		];

		"$mainMod" = "SUPER";

		bind = [
		  "$mainMod, Return, exec, kitty"
		  "$mainMod, w, killactive,"
		  "$mainMod SHIFT, q, exit,"
		  "$mainMod SHIFT, b, exec, ${pkgs.killall}/bin/killall -SIGUSR1 .waybar-wrapped"
		  "$mainMod, f, fullscreen, 0"
		  "$mainMod, m, fullscreen, 1"
		  "$mainMod SHIFT, t, togglefloating,"
		  "$mainMod SHIFT, c, centerwindow,"
		  "$mainMod, Space, submap, leader"

		  "$mainMod ALT, g, movetoworkspace, special:gaming"
		  "$mainMod ALT, i, movetoworkspace, special:idleon"
		  "$mainMod ALT, z, movetoworkspace, special:zoom"
		  "$mainMod ALT, b, movetoworkspace, special:bluetooth"

		  "$mainMod, n, exec, nautilus"
		  "$mainMod, P, pseudo, # dwindle"
		  "$mainMod CTRL, t, togglespecialworkspace, term"

		  "$mainMod, h, movefocus, l"
		  "$mainMod, l, movefocus, r"
		  "$mainMod, k, movefocus, u"
		  "$mainMod, j, movefocus, d"

		  "$mainMod CTRL, h, swapwindow, l"
		  "$mainMod CTRL, l, swapwindow, r"
		  "$mainMod CTRL, k, swapwindow, u"
		  "$mainMod CTRL, j, swapwindow, d"
		  "$mainMod ALT, h, moveintogroup, l"
		  "$mainMod ALT, l, moveintogroup, r"
		  "$mainMod ALT, k, moveintogroup, u"
		  "$mainMod ALT, j, moveintogroup, d"

		  "$mainMod, 1, workspace, 1"
		  "$mainMod, 2, workspace, 2"
		  "$mainMod, 3, workspace, 3"
		  "$mainMod, 4, workspace, 4"
		  "$mainMod, 5, workspace, 5"
		  "$mainMod, 6, workspace, 6"
		  "$mainMod, 7, workspace, 7"
		  "$mainMod, 8, workspace, 8"
		  "$mainMod, 9, workspace, 9"
		  "$mainMod, 0, workspace, 10"

		  "$mainMod ALT, 1, movetoworkspace, 1"
		  "$mainMod ALT, 2, movetoworkspace, 2"
		  "$mainMod ALT, 3, movetoworkspace, 3"
		  "$mainMod ALT, 4, movetoworkspace, 4"
		  "$mainMod ALT, 5, movetoworkspace, 5"
		  "$mainMod ALT, 6, movetoworkspace, 6"
		  "$mainMod ALT, 7, movetoworkspace, 7"
		  "$mainMod ALT, 8, movetoworkspace, 8"
		  "$mainMod ALT, 9, movetoworkspace, 9"
		  "$mainMod ALT, 0, movetoworkspace, 10"

		  ", XF86AudioLowerVolume, exec, pactl -- set-sink-volume 0 -10%"
		  ", XF86AudioRaiseVolume, exec, pactl -- set-sink-volume 0 +10%"
		  ", XF86AudioMute, exec, pactl -- set-sink-mute 0 toggle"
		  ", XF86AudioPrev, exec, playerctl previous"
		  ", XF86AudioNext, exec, playerctl next"
		  ", XF86AudioPlay, exec, playerctl play-pause"
		  ", XF86Calculator, exec, galculator"

		  "$mainMod, bracketright, focusmonitor, r"
		  "$mainMod, bracketleft, focusmonitor, l"
		  "$mainMod ALT, bracketleft, movewindow, mon:-1"
		  "$mainMod ALT, bracketright, movewindow, mon:+1"

		  "$mainMod ALT CTRL, equal, exec, dunstctl set-paused toggle"
		  "$mainMod ALT CTRL, bracketright, exec, systemctl reboot"

		  "CTRL, Print, exec, grimblast copy area"
		  "CTRL SHIFT, Print, exec, grimblast save area"
		  "ALT CTRL SHIFT, Print, exec, grimblast copy active"
		  ", Print, exec, grimblast copy output"
		];

		bindm = [
		  "$mainMod, mouse:272, movewindow"
		  "$mainMod, mouse:273, resizewindow"
		];
	};

	extraConfig = ''
    submap = leader

		bind = , 1, togglespecialworkspace, 1password
		bind = , 1, submap, reset

		bind = , b, exec, kitty --title=btop btop
		bind = , b, submap, reset

    bind = , d, exec, wofi --show drun -I
    bind = , d, submap, reset

		bind = , e, exec, wofi-emoji
		bind = , e, submap, reset

		bind = , f, exec, firefox
		bind = , f, submap, reset

		bind = , g, togglespecialworkspace, gaming
		bind = , g, submap, reset

		bind = , i, togglespecialworkspace, idleon
		bind = , i, submap, reset

		bind = , n, togglespecialworkspace, notes
		bind = , n, submap, reset

		bind = , p, togglespecialworkspace, pdqssh
		bind = , p, submap, reset

		bind = , s, exec, steam
		bind = , s, submap, reset

		bind = , t, togglespecialworkspace, bluetooth
		bind = , t, submap, reset

		bind = , q, togglespecialworkspace, logseq
		bind = , q, submap, reset

		bind = , z, togglespecialworkspace, zoom
		bind = , z, submap, reset

		bind = , w, submap, warcraft
		  submap = warcraft

		  bind = , a, exec, wowup-cf
		  bind = , a, submap, reset

		  bind = , l, exec, appimage-run ~/Downloads/warcraftlogs-v8.16.30.AppImage
		  bind = , l, submap, reset

		  bind = , w, exec, appimage-run ~/Downloads/WagoApp_2.6.1.AppImage
		  bind = , w, submap, reset

      bind = , escape, submap, reset
      bind = , catchall, submap, reset
		  submap = leader

    bind = , escape, submap, reset
    bind = , catchall, submap, reset
		submap = reset
	'';
  };
}
