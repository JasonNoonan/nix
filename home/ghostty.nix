{ pkgs, lib, ... }:

{
  home.packages = [
    pkgs.nerd-fonts.roboto-mono
  ];

  # Create ghostty config manually since the module doesn't support duplicate keys
  home.file.".config/ghostty/config".text = ''
    # Font configuration
    font-family = Cascadia Code
    font-size = 14
    
    # Nerd font symbols for icons
    font-family-bold = Cascadia Code Bold
    font-family-italic = Cascadia Code Italic
    font-family-bold-italic = Cascadia Code Bold Italic
    
    # Embark theme colors
    background = 1e1c31
    foreground = cbe3e7
    
    cursor-color = a1efd3
    
    selection-background = 3e3859
    selection-foreground = cbe3e7
    
    # Embark theme palette
    # Black
    palette = 0=#1e1c31
    palette = 8=#585273
    
    # Red
    palette = 1=#f48fb1
    palette = 9=#f02e6e
    
    # Green
    palette = 2=#a1efd3
    palette = 10=#7fe9c3
    
    # Yellow
    palette = 3=#ffe6b3
    palette = 11=#f2b482
    
    # Blue
    palette = 4=#91ddff
    palette = 12=#78a8ff
    
    # Magenta
    palette = 5=#d4bfff
    palette = 13=#7676ff
    
    # Cyan
    palette = 6=#abf8f7
    palette = 14=#63f2f1
    
    # White
    palette = 7=#cbe3e7
    palette = 15=#8a889d
    
    # Window settings (matching kitty)
    window-decoration = true
    macos-titlebar-style = tabs
    
    # Clipboard settings (matching kitty)
    clipboard-read = allow
    clipboard-write = allow
    clipboard-paste-protection = false
    
    # No confirmation on close (matching kitty)
    quit-after-last-window-closed = true
    
    # Shell integration
    shell-integration = zsh
    shell-integration-features = cursor,sudo,title
    
    # Keybindings
    keybind = ctrl+alt+p=text:rally\r
    keybind = ctrl+alt+r=text:handshake\r
  '';
}
