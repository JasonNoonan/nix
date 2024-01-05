{ pkgs, ... }:
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

    signing.key = "~/.SSH/id_ed25519.pub";
    signing.signByDefault = true;

    aliases = {
	    amend = "commit --amend --no-edit";
	    branches = "!git --no-pager branch --format '%(refname:short)' --sort=-committerdate | ${pkgs.fzf}/bin/fzf --preview 'git log --color=always --decorate {}'" ;
	    co = "checkout";
	    cob = "checkout -b";
	    drop = "!git branch -d $(git branches)";
	    force = "push --force-with-lease";
	    gap = "commit -a --amend --no-edit && git push --force-with-lease";
	    s = "status";
	    to = "!git checkout $(git branches)";
    };

    ignores = [ ".elixir-ls" ".lexical" "json_queries" ".envrc" ".direnv" ".vim" "scratchpad.ex" "json_notes.md" ".DS_Store" "~/.config/nvim/.luarc.json"];

    extraConfig = {
      init = { defaultBranch = "main"; };
      core = { editor = "nvim"; };
      status = { showUntrackedFiles = "all"; };
      blame = { date = "relative"; };
      merge = { conflictStyle = "diff3"; };
      pull = { reabse = false; };
      commit = {
        verbose = true;
      };
      gpg = {
        format = "ssh";
      };
    };
  };
}
