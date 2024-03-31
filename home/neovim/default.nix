{ pkgs, inputs, ... }:
{
  home.packages = [
    pkgs.cargo
    pkgs.nixpkgs-fmt
    pkgs.nodePackages.nodejs
    pkgs.postgresql_14
    pkgs.gnumake
  ];

  programs.lazygit.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  xdg.configFile = {
    nvim = {
      source = inputs.astronvim;
      force = true;
      recursive = true;
    };

    "astronvim/lua/user" = {
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
