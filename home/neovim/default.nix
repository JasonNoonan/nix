{ pkgs, inputs, ... }:
{
  home.packages = [
    pkgs.cargo
    pkgs.lexical
    pkgs.nixpkgs-fmt
    pkgs.nodePackages.nodejs
    pkgs.postgresql_14
    pkgs.gnumake
  ];

  programs.lazygit = {
    enable = true;
    settings = {
      git.paging = {
        colorArg = "always";
        pager = "diff-so-fancy";
      };

      git.commit = {
        autoWrapCommitMessage = true;
        autoWrapWidth = 72;
      };

      gui.theme = {
        activeBorderColor = [
          "#63f2f1"
          "bold"
        ];
        searchingActiveBorderColor = [ "yellow" "bold" ];
        inactiveBorderColor = [ "#8A889D" ];
        selectedLineBgColor = [ "#585273" ];
        optionsTextColor = [ "magenta" ];
      };
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    plugins = with pkgs.vimPlugins; [
      nvim-treesitter.withAllGrammars
    ];
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
