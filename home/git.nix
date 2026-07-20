{ self, pkgs, lib, ... }:

{
  home.packages = [ pkgs.delta ];

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      editor = "nvim";
    };
    extensions = with pkgs; [ gh-dash ];
  };

  # gh-dash renders PR diffs by running `gh pr diff` with GH_PAGER set to
  # `pager.diff`. It does NOT use git's difftool, so `delta` here is what
  # makes those diffs look nice (gh-dash special-cases it, adding --paging).
  xdg.configFile."gh-dash/config.yml".text = ''
    prSections:
    - title: My Pull Requests
      filters: is:open author:@me
    - title: Needs My Review
      filters: is:open review-requested:@me
    - title: Involved
      filters: is:open involves:@me -author:@me
    issuesSections:
    - title: My Issues
      filters: is:open author:@me
    - title: Assigned
      filters: is:open assignee:@me
    - title: Involved
      filters: is:open involves:@me -author:@me
    defaults:
      preview:
        open: true
        width: 50
      prsLimit: 20
      issuesLimit: 20
      view: prs
      layout:
        prs:
          updatedAt:
            width: 7
          repo:
            width: 15
          author:
            width: 15
          assignees:
            width: 20
            hidden: true
          base:
            width: 15
            hidden: true
          lines:
            width: 16
        issues:
          updatedAt:
            width: 7
          repo:
            width: 15
          creator:
            width: 10
          assignees:
            width: 20
            hidden: true
      refetchIntervalMinutes: 30
    keybindings:
      issues: []
      prs: []
    repoPaths: {}
    theme:
      ui:
        table:
          showSeparator: true
    pager:
      diff: delta
  '';

  programs.git = {
    enable = true;

    signing.key = "~/.ssh/github_signing_key_ed25519.pub";
    signing.signByDefault = true;
    signing.format = "ssh";

    settings = {
      init = { defaultBranch = "main"; };
      core = { editor = "nvim"; };
      rerere = { enabled = true; };
      status = { showUntrackedFiles = "all"; };
      blame = { date = "relative"; };
      merge = { conflictStyle = "diff3"; };
      pull = { rebase = false; };
      diff = { tool = "nvimdiff"; };
      difftool = { prompt = false; };
      commit = {
        verbose = true;
        gpgsign = true;
      };

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

      user.email =  "jason.noonan@pdq.com";
      user.name = "Jason Noonan";
    };

    ignores = [ ".elixir-ls" ".lexical" "json_queries" ".envrc" ".erlang-history" ".direnv" ".nix-mix" ".vim" "scratchpad.ex" "json_notes.md" ".DS_Store" "~/.config/nvim/.luarc.json" ".opencode/" ".dexter.db*"];
  };

  programs.diff-so-fancy = {
    enable = true;
    enableGitIntegration = true;
    settings = {
      stripLeadingSymbols = true;
      changeHunkIndicators = true;
    };
  };
}
