local wezterm = require 'wezterm'
local config = {};
return {
    audible_bell = "SystemBeep",

    font = wezterm.font_with_fallback{
        "0xProto Nerd Font Mono",
        "0xProto",
        "Cica",
    },

    font_size = 10.5,

    harfbuzz_features = { "calt = 0", "clig = 0", "liga = 0" },

    hide_tab_bar_if_only_one_tab = true,

    color_scheme = "Catppuccin Macchiato",

    initial_cols = 170,
    initial_rows = 70,

    default_cursor_style = "BlinkingBar",
    cursor_blink_rate = 600,

    default_cwd = "$HOME",

    exit_behavior = "Close",
    keys = {
        { key = 't', mods = 'SUPER', action = wezterm.action.SpawnCommandInNewTab { cwd = '~' } },
    },

    default_prog = {"tmux"},
}

