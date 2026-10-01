{ inputs, pkgs, lib, config, ... }:

let
  cfg = config.lang.elixir;
in
{
  options.lang.elixir.useNixToolchain = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Install elixir/erlang from nixpkgs. Disable on hosts where mise manages
      the BEAM toolchain: mise shims fall through to the next binary on PATH
      when no version is active, so a Nix copy silently shadows the pinned one.
    '';
  };

  config = lib.mkMerge [
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
                  "#{IO.ANSI.magenta} #{IO.ANSI.reset}(%counter) |"
              )
      '';

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

    (lib.mkIf cfg.useNixToolchain {
      home.packages = with pkgs; [
        beamPackages.elixir
        beamPackages.erlang
        # LSP is provided by dexter (see home/neovim); elixir-ls no longer needed.
        # (inputs.lexical-lsp.lib.mkLexical { erlang = beam.packages.erlangR26; })
      ];
    })

    # Global fallback for dirs without a pinned version. Lives in conf.d so
    # ~/.config/mise/config.toml stays writable for `mise use -g`.
    (lib.mkIf (!cfg.useNixToolchain) {
      xdg.configFile."mise/conf.d/elixir.toml".text = ''
        [tools]
        erlang = "28.3"
        elixir = "1.19.5-otp-28"
      '';
    })
  ];
}
