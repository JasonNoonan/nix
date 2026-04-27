{ pkgs, lib, config, ... }:

{
  home.packages = [
    pkgs.cascadia-code
    pkgs.browsh
    pkgs.diff-so-fancy
    pkgs.entr
    pkgs.eslint_d
    pkgs.fd
    pkgs.hurl
    pkgs.jq
    pkgs.lazydocker
    pkgs.llvmPackages_20.libcxxClang
    pkgs.powershell
  ];

  programs.bat = {
    enable = true;
    config = { theme = "claret"; };
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
      claret = {
        src = pkgs.fetchFromGitHub {
          owner = "cfbender";
          repo = "claret.nvim";
          rev = "233e72d";
          sha256 = "sha256-tON0+meS37gKW2Hqp/93So1z04LKr/bllrwPe7X6XN0=";
        };
        file = "ports/bat/ClaretDark.tmTheme";
      };
    };
  };

  programs.btop = {
    enable = true;
    settings = {
      # No claret port available for btop; using default theme
      vim_keys = true;
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
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

  programs.keychain = {
    enable = true;
    enableZshIntegration = true;
    keys = [
      "github_login_key_ed25519"
    ];
  };

  programs.ripgrep.enable = true;

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = "$character$jobs$directory$git_branch$git_status ";

      character = {
        format = "$symbol";
        error_symbol = "[ I ](bold fg:red bg:#180810)";
        success_symbol = "[ I ](bold fg:green bg:#180810)";
        vimcmd_symbol = "[ N ](bold fg:yellow bg:#180810)";
      };

      directory = {
        format = "[   $path ](bg:#2B1F22 fg:bright-white)[](fg:#2B1F22)";
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
        format = "[ $symbol$status ](fg:bright-white bg:#2B1F22)";
        disabled = false;
        symbol = " ";
      };

      hostname = {
        ssh_only = false;
        format = "[ $hostname ](italic fg:bright-white bg:#180810)";
      };
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    dotDir = "${config.xdg.configHome}/zsh";

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
      dev_env = "~/workspace/devops/scripts/dev-secrets/create-file.sh";
      ffproxy = "ssh -D 8080 -q -C -N pdq";
    };

    initContent = let
      zshEarlyInit = lib.mkOrder 550 ''
        setopt AUTO_PUSHD           # Push the old directory onto the stack on cd
        setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack
        setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd
        setopt CORRECT              # Spelling Corrections
        setopt CDABLE_VARS          # Change directory to a path stored in a variable
        setopt EXTENDED_GLOB        # Use extended globbing syntax
        KEYTIMEOUT=5
      '';

      zshInit = with pkgs; ''
        autoload -Uz edit-command-line
        zle -N edit-command-line
        bindkey -M viins '^f' edit-command-line
        bindkey -M vicmd '^i' edit-command-line
        source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
        tput setaf ''${$(( ( RANDOM % 6 ) + 1 ))} && printf "%*s\n" $(((''${#title}+$COLUMNS)/2)) "EYES UP, GUARDIAN"
        ssh-add --apple-load-keychain 2> /dev/null
        if command -v keychain > /dev/null 2>&1; then eval $(keychain --eval --nogui ~/.ssh/github_login_key_ed25519 --quiet); fi
        eval "$(mise activate zsh)"

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

        function disc() {
          echo "<t:$(date -d$1 +%s):f>"
        }

        function sidekick() {
          sudo docker compose --project-directory ~/workspace/Sidekick up -d
        }

        function clear_cache() {
          sync && sudo sysctl -w vm.drop_caches=3
        }
      '';
    in
      lib.mkMerge [ zshEarlyInit zshInit ];

    envExtra = ''
      export LANG="en_US.UTF-8"
      export LC_ALL="en_US.UTF-8"
      export MANPAGER="nvim +Man!"
      export PAGER=bat
      export TODO_DB_PATH=$HOME/.config/td/.todos.json
      export PATH="$HOME/.local/share/mise/shims:$PATH"
    '';
  };
}
