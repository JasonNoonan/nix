{ pkgs, lib, config, ... }:

let
  rally = import ./rally.nix { inherit pkgs; };
in
{
  home.packages = [
    rally
    pkgs.smug
    (pkgs.callPackage ./tmux-file-paths.nix { })
  ];

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 10000;
    keyMode = "vi";
    mouse = true;
    terminal = "tmux-256color";
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      tmux-fzf
      {
        plugin = fuzzback;
        extraConfig = '' 
        set -g @fuzzback-popup 1 
        set -g @fuzzback-popup-size '90%' 
        set -g @fuzzback-fzf-colors '${lib.strings.concatStringsSep "," (lib.attrsets.mapAttrsToList (name: value: name + ":" + value) config.programs.fzf.colors)}'
        set -g @fuzzback-bind = 
        '';
      }
      # Invoke the shell for this again for the status line to actually not cry
      {
        plugin = cpu;
        extraConfig = ''
          set -g @cpu_low_icon ' '
          set -g @cpu_medium_icon ' '
          set -g @cpu_high_icon ' '
          set -g @ram_low_icon '󰑭'
          set -g @ram_medium_icon '󰑭'
          set -g @ram_high_icon '󰑭'
        '';
      }
    ];

    extraConfig = ''
      set -g allow-passthrough on
      set -gw xterm-keys on
      set -g focus-events on
      set -as terminal-features ',xterm*:RGB'
      set -g status-interval 5
      set set-clipboard on
      set -g automatic-rename off
      set -g renumber-windows

      bind g switch-client -Ttable1
      bind @ new-window \; send-keys 'gh dash' C-m

      bind | split-window -h -l 33%
      bind \\ split-window -v -l 33%
      bind ? new-window btop
      bind ! kill-server
      bind g display-popup -E -w 80% -h 80% lazygit
      bind s display-popup -E -w 80% -h 70% rally
      bind S display-popup -E 'tmux switch-client -t "fzf list-sessions -F "#{session_name}"| fzf)"'
      bind > display-popup -E -w 50% -h 50%
      bind H resize-pane -L 10
      bind J resize-pane -D 10
      bind K resize-pane -U 10
      bind L resize-pane -R 10
      bind BSpace switch-client -l
      bind -n S-Left previous-window
      bind -n S-Right next-window

      set -g status-interval 3
      set-option -g status-position bottom
      set-option -g pane-active-border-style "bg=black,fg=magenta"
      set-option -g pane-border-style "fg=brightwhite"
      set-option -g message-style "bg=green,fg=black"
      set-option -g message-command-style "bg=green,fg=black"
      set -g popup-border-style "fg=#585273"
      set -g popup-border-lines "rounded"

      # Status line
      set -g status-right-length 80
      set -g status-left-length 100
      set -g window-status-separator ""
      set -g status-bg "black"

      #Bars ---------------------------------
      set -g status-left "#[bg=#19172C,fg=brightwhite italics] 󰞇 #S#[fg=#19172C,bg=black]"

      set -g status-right "#[fg=#37354A]#[bg=#37354A,fg=brightwhite] %Y-%m-%d #[fg=#37354A,bg=#2D2B40] #[fg=brightwhite,bg=#2D2B40]%I:%M#[fg=#2D2B40]#[fg=#19172C,bg=#2D2B40]#[bg=#19172C,fg=brightwhite italics] #{cpu_icon} #{cpu_percentage} #{ram_icon} #{ram_percentage} "

      # Windows ------------------------------
      set -g status-justify left

      set -g window-status-format "#[fg=#2D2B40]#[fg=brightwhite,bg=#2D2B40] #{?window_zoomed_flag,󰆞 ,}#W #[bg=black,fg=#2D2B40]"
      set -g window-status-current-format "#[fg=green]#[bg=green,fg=black] #W #{?window_zoomed_flag,󰆞 ,}#[fg=green,bg=black]"
      run-shell ${pkgs.tmuxPlugins.cpu}/share/tmux-plugins/cpu/cpu.tmux
    '';
  };

  xdg.configFile.smug = {
    source = ./smug;
    recursive = true;
    force = true;
  };
}
