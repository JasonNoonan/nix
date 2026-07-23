{ inputs, pkgs, ... }:

{
  home.sessionVariables = {
    ERL_AFLAGS = "-kernel shell_history enabled";
  };

  home.sessionPath = [
    "$HOME/.mix/escripts"
  ];

  home.file.".iex.exs".text = ''
    IEx.configure(
            default_prompt:
              "#{IO.ANSI.magenta} #{IO.ANSI.reset}(%counter) |"
          )
  '';

  home.packages = with pkgs; [
    beamPackages.elixir
    beamPackages.erlang
    # LSP is provided by dexter (see home/neovim); elixir-ls no longer needed.
    # (inputs.lexical-lsp.lib.mkLexical { erlang = beam.packages.erlangR26; })
  ];

  programs.zsh.shellAliases = {
    ips = "iex -S mix phx.server";
    mco = "mix coveralls";
    mcoh = "mix coveralls.html";
    mcr = "mix credo --strict";
    mdc = "mix deps.compile";
    mdg = "mix deps.get";
    mdl = "mix dialyzer";
    meips = "mise exec -- iex -S mix phx.server";
    mes = "mix ecto.setup";
  };
}
