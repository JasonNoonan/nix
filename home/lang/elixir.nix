{ inputs, pkgs, ... }:

{
  home.sessionVariables = {
    ERL_AFLAGS = "-kernel shell_history enabled";
  };

  home.file.".iex.exs".text = ''
    IEx.configure(
            default_prompt:
              "#{IO.ANSI.magenta} #{IO.ANSI.reset}(%counter) |",
            continuation_prompt:
              "#{IO.ANSI.magenta} #{IO.ANSI.reset}(.) |"
          )
  '';

  home.packages = with pkgs; [
    elixir
    erlang
    elixir-ls
    # (inputs.lexical-lsp.lib.mkLexical { erlang = beam.packages.erlangR26; })
  ];

  programs.zsh.shellAliases = {
    ips = "iex -S mix phx.server";
    mco = "mix coveralls";
    mcoh = "mix coveralls.html";
    mdl = "mix dialyzer";
    mcr = "mix credo --strict";
    mdc = "mix deps.compile";
    mdg = "mix deps.get";
    mes = "mix ecto.setup";
  };
}
