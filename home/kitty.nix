{ pkgs, lib, ... }:

{
  home.packages = [
    pkgs.nerd-fonts.roboto-mono
  ];

  xdg.configFile."kitty/themes/embark-theme.conf".source = pkgs.fetchFromGitHub
    {
      repo = "kitty";
      owner = "embark-theme";
      rev = "50017a4";
      sha256 = "sha256-rlaRgsAHGy+7lV7UXC8ZGmShcZbhhmlK08W5z1MrnX8=";
    } + "/embark-theme.conf";

  programs.kitty = {
    enable = true;

    font = {
      package = pkgs.cascadia-code;
      name = "Cascadia Code";
      size = 14;
    };

    keybindings = {
      "ctrl+alt+p" = "send_text all rally\\r";
      "ctrl+alt+r" = "send_text all handshake\\r";
    };

    settings = {
      macos_titlebar_color = "background";
      clipboard_control = "write-clipboard write-primary no-append";
      confirm_os_window_close = "0";
    };

    shellIntegration.enableZshIntegration = true;

    extraConfig = ''
      # Seti
      symbol_map U+E5FA-U+E6B1 RobotoMono Nerd Font
      # Devicons
      symbol_map U+E700-U+E7C5 RobotoMono Nerd Font
      # Font Awesome
      symbol_map U+F000-U+F2E0 RobotoMono Nerd Font
      # Font Awesome Extension
      symbol_map U+E200-U+E2A9 RobotoMono Nerd Font
      # Material Design
      symbol_map U+F0001-U+F1AF0 RobotoMono Nerd Font
      # Weather
      symbol_map U+E300-U+E3E3 RobotoMono Nerd Font
      # Octicons
      symbol_map U+F400-U+F532,U+2665-U+26A1 RobotoMono Nerd Font
      # Powerline
      symbol_map U+E0A0-U+E0A2,U+E0B0-U+E0B3 RobotoMono Nerd Font
      # Powerline Extras
      symbol_map U+E0A3,U+E0B4-U+E0C8,U+E0CA-U+E0D4 RobotoMono Nerd Font
      # IEC Power
      symbol_map U+23FB-U+23FE,U+2B58 RobotoMono Nerd Font
      # Font Logos
      symbol_map U+F300-U+F372 RobotoMono Nerd Font
      # Pomicons
      symbol_map U+E000-U+E00A RobotoMono Nerd Font
      # Codeicons
      symbol_map U+EA60-U+EBEB RobotoMono Nerd Font

      include themes/embark-theme.conf
    '';
  };
}
