{ self, pkgs, lib, ... }:

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

    signing.key = "~/.ssh/github_signing_key_ed25519.pub";
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

    ignores = [ ".elixir-ls" ".lexical" "json_queries" ".envrc" ".erlang-history" ".direnv" ".nix-mix" ".vim" "scratchpad.ex" "json_notes.md" ".DS_Store" "~/.config/nvim/.luarc.json" ".opencode/"];

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
      pull = { rebase = false; };
      diff = { tool = "${pkgs.diff-so-fancy}"; };
      gpg = { format = "ssh"; };
      commit = {
        verbose = true;
        gpgsign = true;
      };
    };
  };
}
