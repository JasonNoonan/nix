{ pkgs, lib, config, ... }:

{
  home.packages = with pkgs; [ 
    inter 
    libnotify 
    mpv 
    noto-fonts
    playerctl 
  ];

  services.dunst = {
      enable = true;
      iconTheme = {
        name = "Fluent-dark";
        package = pkgs.fluent-icon-theme;
      };
      settings = {
        global = {
          font = "Inter 12";
          frame_color = "#100E23";
          frame_width = "2";
          origin = "top-right";
          offset = "8x4";
          width = "300";
          height = "200";
          padding = 16;
          horizontal_padding = 16;
          separator_color = "#585273";
          follow = "mouse";
        };

        urgency_low = {
          background = "#2D2B40";
        };

        urgency_normal = {
          background = "#2D2B40";
          script = "/home/orlando/.config/dunst/play_normal.sh";
        };

        urgency_critical = {
          background = "#2D2B40";
          foreground = "#CBE3E7";
          frame_color = "#F48FB1";
          script = "/home/orlando/.config/dunst/play_critical.sh";
        };
      };
    };

    xdg.configFile."dunst/play_critical.sh" = {
      executable = true;
      text = "${pkgs.mpv}/bin/mpv ${pkgs.kdePackages.ocean-sound-theme}/share/sounds/ocean/stereo/dialog-question.oga";
    };

    xdg.configFile."dunst/play_normal.sh" = {
      executable = true;
      text = "${pkgs.mpv}/bin/mpv ${pkgs.kdePackages.ocean-sound-theme}/share/sounds/ocean/stereo/desktop-login.oga";
    };

    services.playerctld.enable = true;

    programs.waybar = {
      enable = true;
      systemd.enable = true;
      systemd.target = "graphical-session.target";
      package = pkgs.waybar.overrideAttrs (oldAttrs: { mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ]; });
      settings = {
        mainBar = {
          start_hidden = false;
          margin = "0";
          layer = "top";
          modules-left = [ "hyprland/workspaces" "mpris" ];
          modules-center = [ "wlr/taskbar" ];
          modules-right = [ "network#interface" "network#speed" "pulseaudio" "cpu" "temperature" "backlight" "battery" "clock" "custom/notification" "tray" ];

          persistent_workspaces = {
            "1" = [ ];
            "2" = [ ];
            "3" = [ ];
            "4" = [ ];
          };

          "hyprland/workspaces" = {
            format = "{icon}";
            on-click = "activate";
            sort-by-number = true;
            format-icons = {
              "default" = "";
              "active" = "";
            };
          };

          mpris = {
            format = "{status_icon}<span weight='bold'>{artist}</span> | {title}";
            status-icons = {
              playing = "󰎈 ";
              paused = "󰏤 ";
              stopped = "󰓛 ";
            };
          };

          "wlr/taskbar" = {
            on-click = "activate";
          };

          "network#interface" = {
            format-ethernet = "󰣶 {ifname}";
            format-wifi = "󰖩 {ifname}";
            tooltip = true;
            tooltip-format = "{ipaddr}";
          };

          "network#speed" = {
            format = "⇡{bandwidthUpBits} ⇣{bandwidthDownBits}";
          };

          pulseaudio = {
            format = "󰓃 {volume}%";
            on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
          };

          cpu = {
            format = " {usage}% 󱐌{avg_frequency}";
          };

          temperature = {
            format = "{icon} {temperatureC} °C";
            format-icons = [ "" "" "" "󰈸" ];
          };

          backlight = {
            format = "{icon} {percent}%";
            format-icons = [ "󰃜" "󰃛" "󰃚 " ];
          };

          battery = {
            format-critical = "{icon} {capacity}%";
            format = "{icon} {capacity}%";
            format-icons = [ "󰁺" "󰁾" "󰂀" "󱟢" ];
          };

          clock = {
            format = " {:%H:%M}";
            format-alt = "󰃭 {:%Y-%m-%d}";
          };

          "custom/notification" = {
            exec = "~/.config/waybar/scripts/dunst.sh";
            tooltip = false;
            on-click = "dunstctl set-paused toggle";
            restart-interval = 1;
          };

          tray = {
            icon-size = 16;
            spacing = 8;
          };
        };
      };

      style = ''
        * {
          min-height: 0;
        }

        window#waybar {
          font-family: 'Noto', 'RobotoMono Nerd Font';
          font-size: 10px;
        }

        tooltip {
          background: @unfocused_borders;
        }

        #custom-nix {
          padding: 0px 4px;
        }

        #workspaces button {
          padding: 0px 4px;
          margin: 0 4px 0 0;
        }

        .modules-right * {
          padding: 0 4px;
          margin: 0 0 0 4px;
        }

        #mpris {
          padding: 0 4px;
        }

        #custom-notification {
          padding: 0 4px 0 4px;
        }

        #tray {
          padding: 0 4px;
        }
      
        #tray * {
          padding: 0;
          margin: 0;
        }
      '';
    };

    xdg.configFile."waybar/scripts/dunst.sh" = {
      text = ''
        COUNT=$(dunstctl count waiting)
        ENABLED="󰂚 "
        DISABLED="󰂛 "
        if [ $COUNT != 0 ]; then DISABLED="󱅫 "; fi
        if dunstctl is-paused | grep -q "false"; then
          echo $ENABLED
        else
          echo $DISABLED
        fi
      '';
      executable = true;
    };
}
