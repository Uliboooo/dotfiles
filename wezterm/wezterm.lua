local wezterm = require 'wezterm'

return {
    audible_bell = "SystemBeep",

    font = wezterm.font_with_fallback{
        "0xProto",
        "Cica",
    },

    font_size = 10.0,

    hide_tab_bar_if_only_one_tab = true,

    color_scheme = "Catppuccin Macchiato",

    initial_cols = 170,
    initial_rows = 70,

    default_cursor_style = "BlinkingBar",
    cursor_blink_rate = 600,
}

