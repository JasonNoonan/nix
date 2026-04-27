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
    
    # Claret theme colors
    background = 180810
    foreground = DDD3C7

    cursor-color = D4A76A

    selection-background = 2B1F22
    selection-foreground = DDD3C7

    # Claret theme palette
    # Black
    palette = 0=#211618
    palette = 8=#3A2E25

    # Red
    palette = 1=#C44536
    palette = 9=#B33A2E

    # Green
    palette = 2=#8FA86E
    palette = 10=#8FA86E

    # Yellow
    palette = 3=#D4A76A
    palette = 11=#C5975B

    # Blue
    palette = 4=#8995A8
    palette = 12=#8995A8

    # Magenta
    palette = 5=#C75B7A
    palette = 13=#B04A68

    # Cyan
    palette = 6=#7A9460
    palette = 14=#7A9460

    # White
    palette = 7=#BDB3A7
    palette = 15=#DDD3C7
    
    # Window settings (matching kitty)
    window-decoration = true
    macos-titlebar-style = tabs
    
    # Clipboard settings (matching kitty)
    clipboard-read = allow
    clipboard-write = allow
    clipboard-paste-protection = false
    
    # No confirmation on close (matching kitty)
    quit-after-last-window-closed = true
    
    # Terminal type - use widely supported xterm-256color for SSH compatibility
    term = xterm-256color
    
    # Bell
    bell-features = audio

    # Shell integration
    shell-integration = zsh
    shell-integration-features = cursor,sudo,title
    
    # Keybindings
    keybind = ctrl+alt+p=text:rally\r
    keybind = ctrl+alt+r=text:handshake\r
    
    # Pass through keys directly to applications (e.g., tmux)
    keybind = ctrl+b=unbind
    keybind = ctrl+v=unbind
    keybind = ctrl+j=unbind
  '';
}
