{ pkgs, lib, ... }:
{
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      editor = "nvim";
    };
    extensions = with pkgs; [ gh-dash ];
  };

  programs.git = {
    enable = true;
    userEmail = "jason.noonan@pdq.com";
    userName = "Jason Noonan";

    signing.key = "~/.ssh/id_ed25519.pub";
    signing.signByDefault = true;

    aliases = {
      amend = "commit --amend --no-edit";
      branches = "!git --no-pager branch --format '%(refname:short)' --sort=-committerdate | ${pkgs.fzf}/bin/fzf --preview 'git log --color=always --decorate {}'";
      co = "checkout";
      cob = "checkout -b";
      drop = "!git branch -d $(git branches)";
      force = "push --force-with-lease";
      gap = "commit -a --amend --no-edit && git push --force-with-lease";
      s = "status";
      to = "!git checkout $(git branches)";
    };

    ignores = [ ".elixir-ls" ".lexical" "json_queries" ".envrc" ".direnv" ".vim" "scratchpad.ex" "json_notes.md" ".DS_Store" "~/.config/nvim/.luarc.json" ];

    diff-so-fancy = {
      enable = true;
      stripLeadingSymbols = true;
      changeHunkIndicators = true;
    };

    extraConfig = {
      init = { defaultBranch = "main"; };
      core = { editor = "nvim"; };
      status = { showUntrackedFiles = "all"; };
      blame = { date = "relative"; };
      merge = { conflictStyle = "diff3"; };
      pull = { reabse = false; };
      commit = {
        verbose = true;
        gpgsign = true;
      };
      gpg = {
        format = "ssh";
      };

      "gpg \"ssh\"" = {
        program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
      };
      diff = {
        tool = "${pkgs.diff-so-fancy}";
      };
      user = {
        signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDLucPLtqI2jSFkglo3ldfdPPnYWxoh5r9qum9UV078o";
      };
    };
  };
}
