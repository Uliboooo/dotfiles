hl.config({
  general = {
    gaps_in = 2,
    gaps_out = 4,
    border_size = 3,

    -- layout = "dwindle",
    layout = "scrolling",

    col = {
      -- Active: barely-there mauve (matches waybar #clock)
      active_border = "rgba(cba6f7cc)",
      -- Inactive: nearly invisible
      inactive_border = "rgba(2a1f3d1a)",
    },
  },

  dwindle = {
    smart_split = false,
    preserve_split = true,
  },

  scrolling = {
    -- niri-style resize toggle: cycled with colresize +conf/-conf
    explicit_column_widths = "0.25, 0.333, 0.5",
  },

  decoration = {
    rounding = 6,

    active_opacity = 1.0,
    inactive_opacity = 1.0,
    fullscreen_opacity = 1.0,

    dim_inactive = false,
    -- dim_strength = 0.04,

    blur = {
      enabled = true,
      size = 2,
      passes = 1,
      new_optimizations = true,
      ignore_opacity = false,
      xray = false,
    },

    shadow = {
      enabled = false,
    },
  },

  input = {
    kb_layout = "us",
    kb_options = "ctrl:swap_lalt_lctl,ctrl:swap_ralt_rctl,caps:super",

    natural_scroll = true,

    follow_mouse = 1,

    sensitivity = 0,

    repeat_delay = 230,
    repeat_rate = 42,

    touchpad = {
      natural_scroll = false,
      scroll_factor = 0.5,
    },
  },
})
