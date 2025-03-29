{ config, pkgs, ... }: let
  # check the nix wiki for 1password config:
  # https://nixos.wiki/wiki/1Password
  onePassPath = "~/.1password/agent.sock";
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
    microsoft-edge
    nautilus
    obs-studio
    pavucontrol
    protonup
    slack
    spotify
    steam
    udiskie
    udisks
    usbutils
    unzip
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
    extraConfig = ''
  Host *
    IdentityAgent ${onePassPath}
    '';
    matchBlocks = {
      "pdq" =
        {
          hostname = "192.168.86.34";
          user = "jasonnoonan";
          dynamicForwards = [{ port = 8080; }];

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

  programs.zsh.shellAliases.handshake = "${pkgs.nh}/bin/nh os switch /etc/nixos";

  wayland.windowManager.hyprland = {
	enable = true;
	xwayland.enable = true;
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
      "HDMI-A-1, 3840x2160@25, 0x0, 1"
      "DP-3, 3440x1440@144, 213x2160, 1, vrr, 1"
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

		windowrulev2 = [
		  "workspace 2,class:kitty"
		  "workspace 1,title:^(Mozilla Firefox)(.*)$"
		  "workspace 1,class:firefox"
		  "workspace 1,class:Microsoft-edge"
		  "workspace 5,class:Slack"
		  "workspace special:idleon,title:(Legends Of Idleon)"
		  "workspace special:1password,class:1Password"
		];

		"$mainMod" = "SUPER";

		bind = [
      "$mainMod, r, togglespecialworkspace, idleon"
		  "$mainMod, Return, exec, kitty"
		  "$mainMod, w, killactive,"
		  "$mainMod SHIFT, q, exit,"
		  "$mainMod SHIFT, b, exec, ${pkgs.killall}/bin/killall -SIGUSR1 .waybar-wrapped"
		  "$mainMod, f, fullscreen, 0"
		  "$mainMod, m, fullscreen, 1"
		  "$mainMod SHIFT, t, togglefloating,"
		  "$mainMod, Space, submap, leader"

		  # "$mainMod, r, exec, kitty --title='kitty-float' --override initial_window_width=100c --override initial_window_height=1c --hold"
		  "$mainMod CTRL, r, exec, kitty --title='kitty-float' --override initial_window_width=100c --override initial_window_height=40c --hold"
		  "$mainMod, o, exec, kitty --title='kitty-float' --override initial_window_width=150c --override initial_window_height=42c zsh -ic 'zk edit --interactive'"
		  "$mainMod, e, exec, kitty --title='kitty-float' --override initial_window_width=80c --override initial_window_height=20c qke"

		  "$mainMod, n, exec, nautilus"
		  "$mainMod, P, pseudo, # dwindle"
		  "$mainMod, s, togglespecialworkspace, notes"
		  "$mainMod SHIFT, S, movetoworkspace, special:notes"
		  "$mainMod CTRL, t, togglespecialworkspace, term"
		  "$mainMod, g, togglegroup"
		  "$mainMod, TAB, changegroupactive, f"
		  "$mainMod SHIFT, TAB, changegroupactive, b"
		  "$mainMod, z, focuswindow, title:kitty-journal"
		  "$mainMod, period, exec, zsh -c 'wl-paste >> $JOURNALS/$(date +%Y-%m-%d).md && notify-send \"pasted into $(date +%Y-%m-%d).md!\"'"
		  "$mainMod, v, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy"

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

    bind = , d, exec, wofi --show drun -I
		bind = , e, exec, wofi-emoji
		bind = , 1, togglespecialworkspace, 1password

    bind = , escape, submap, reset
    bind = , catchall, submap, reset
    submap = reset
	'';
  };
}
