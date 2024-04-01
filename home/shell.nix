{ pkgs, lib, ... }:

{
  home.packages = [
    pkgs.entr
    pkgs.fd
    pkgs.hurl
    pkgs.lazydocker
    pkgs.powershell
  ];

  programs.bat = {
    enable = true;
    config = { theme = "embark"; };
    themes = {
      catppuccin-mocha = {
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "bat";
          rev = "ba4d168";
          # sha256 = lib.fakeSha256;
          sha256 = "sha256-6WVKQErGdaqb++oaXnY3i6/GuH2FhTgK0v4TN4Y0Wbw=";
        };
        file = "Catppuccin-mocha.tmTheme";
      };
      embark = {
        src = pkgs.fetchFromGitHub {
          owner = "embark-theme";
          repo = "bat";
          rev = "fae7e23";
          sha256 = "sha256-7xKdf5IRwRQo7nVc9hXb+ziULBtwhAn3pbOy4FiRbiQ=";
        };
        file = "Embark.tmTheme";
      };
    };
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "embark";
      vim_keys = true;
    };
  };

  xdg.configFile."btop/themes/embark.theme".source = pkgs.fetchFromGitHub
    {
      owner = "embark-theme";
      repo = "bashtop";
      rev = "e8dc8e6";
      sha256 = "sha256-HHoCVdCH4jCIK0JzoYagURcU722sBARtFkNeGPXuCNM=";
    } + "/embark.theme";

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.eza = {
    enable = true;
    enableAliases = true;
    icons = true;
    extraOptions = [ "--group-directories-first" "--header" ];
    git = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    colors = {
      "bg+" = "-1";
      "fg" = "-1";
      "fg+" = "-1";
      "prompt" = "6";
      "header" = "5";
      "pointer" = "2";
      "hl" = "2";
      "hl+" = "2";
      "spinner" = "05";
      "info" = "15";
      "border" = "15";
    };
    defaultCommand = "${pkgs.ripgrep}/bin/rg --files --hidden -g !.git";
    defaultOptions = [ "--reverse" "--ansi" ];
  };

  programs.ripgrep.enable = true;

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = "$character$jobs$directory$git_branch$git_status ";

      character = {
        format = "$symbol";
        error_symbol = "[ I ](bold fg:red bg:#19172C)";
        success_symbol = "[ I ](bold fg:green bg:#19172C)";
        vimcmd_symbol = "[ N ](bold fg:yellow bg:#19172C)";
      };

      directory = {
        format = "[   $path ](bg:#2D2B40 fg:bright-white)[](fg:#2D2B40)";
      };

      git_branch = {
        format = "[  $branch ](fg:bright-white)";
      };

      git_status = {
        style = "bold purple";
      };

      jobs = {
        symbol = " 󰠜 ";
        style = "bright-white";
      };

      status = {
        format = "[ $symbol$status ](fg:bright-white bg:#2D2B40)";
        disabled = false;
        symbol = " ";
      };

      hostname = {
        ssh_only = false;
        format = "[ $hostname ](italic fg:bright-white bg:#19172C)";
      };
    };
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    dotDir = ".config/zsh";

    autocd = true;
    cdpath = [ "." "$HOME/.config" "$HOME/workspace" ];
    defaultKeymap = "viins";

    plugins = [
      # { name = "fzf-tab"; src = "${pkgs.zsh-fzf-tab}/share/fzf-tab"; }
    ];

    shellAliases = {
      gap = "git commit -a --amend --no-edit && git push --force-with-lease";
      clean = "rm package-lock.json && rm -rf ./node_modules && npm i";
      cloudsql = "cloud_sql_proxy -instances=staging-e49c5d9c:us-central1:portal=tcp:5433";
      tunnel = "~/workspace/devops/scripts/k8s-tunnel.sh";
      cat = "${pkgs.bat}/bin/bat";
      clearNvimCache = "rm -rf ~/.local/share/nvim";
      zso = "source $HOME/.zshrc && source $HOME/.zshenv";
      rm = "${pkgs.trash-cli}/bin/trash-put -v";
      cp = "cp -iv";
      mv = "mv -iv";
      handshake = "darwin-rebuild switch --flake ~/.config/nix-darwin";
      dev_env = "~/workspace/devops/scripts/dev-secrets/create-file.sh";
    };

    initExtra = with pkgs; ''
      autoload -Uz edit-command-line
      zle -N edit-command-line
      bindkey -M viins '^f' edit-command-line
      bindkey -M vicmd '^i' edit-command-line
      source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
      tput setaf ''${$(( ( RANDOM % 6 ) + 1 ))} && printf "%*s\n" $(((''${#title}+$COLUMNS)/2)) "EYES UP, GUARDIAN"
      ssh-add --apple-load-keychain 2> /dev/null

      function fgo() {
        target=$(command ls -d ~/* ~/workspace/* ~/.config/* ~/dots | ${fzf}/bin/fzf --preview "${eza}/bin/eza --tree --icons --level=3 --git-ignore {}")

        cd $target
        nvim
      }

      function w() {
        ${fd}/bin/fd $1 | ${entr}/bin/entr -c "''${@:2}"
      }

      function ew() {
        ${fd}/bin/fd "\.exs?$" | ${entr}/bin/entr -c "$@"
      }
    '';

    initExtraBeforeCompInit = ''
      setopt AUTO_PUSHD           # Push the old directory onto the stack on cd
      setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack
      setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd
      setopt CORRECT              # Spelling Corrections
      setopt CDABLE_VARS          # Change directory to a path stored in a variable
      setopt EXTENDED_GLOB        # Use extended globbing syntax
      KEYTIMEOUT=5
    '';

    envExtra = ''
      export MANPAGER="nvim +Man!"
      export PAGER=bat
    '';
  };
}
