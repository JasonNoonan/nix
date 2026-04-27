{ pkgs, inputs, ... }:
{
  home.packages = [
    pkgs.nixpkgs-fmt
    pkgs.nodejs
    pkgs.dexter
    pkgs.postgresql_14
    pkgs.rustup
    pkgs.gnumake
    pkgs.lua51Packages.luarocks
  ];

  programs.lazygit = {
    enable = true;
    settings = {
      git.pagers = [
        {
        colorArg = "always";
        pager = "diff-so-fancy";
        }
      ];

      git.commit = {
        autoWrapCommitMessage = true;
        autoWrapWidth = 72;
      };

      git.overrideGpg = true;

      gui.theme = {
        activeBorderColor = [
          "#C75B7A"
          "bold"
        ];
        searchingActiveBorderColor = [ "yellow" "bold" ];
        inactiveBorderColor = [ "#3A2E25" ];
        selectedLineBgColor = [ "#2B1F22" ];
        optionsTextColor = [ "magenta" ];
      };
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withPython3 = true;
    withRuby = true;
    plugins = [];
  };

  xdg.configFile = {
    nvim = {
      source = ./neovim;
      force = true;
      recursive = true;
    };

    "nvim/after/queries/markdown/highlights.scm".text = ''
      ;; extends

      ;; replace '- [x]' with 󰄲
      ((task_list_marker_checked) @text.todo.checked
        (#offset! @text.todo.checked 0 -2 0 0)
        (#set! conceal "󰄲")
      )

      ;; replace '- [ ]' with 󰄱
      ((task_list_marker_unchecked) @text.todo.unchecked
        (#offset! @text.todo.unchecked 0 -2 0 0)
        (#set! conceal "󰄱")
      )
    '';
  };
}
