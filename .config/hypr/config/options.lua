hl.config({
  general = {
    gaps_in = 2,
    gaps_out = 4,
    border_size = 3,

    layout = "dwindle",

    col = {
      active_border = "rgba(DFC3E4cf)",
      inactive_border = "rgba(4F3360ff)",
    },
  },

  dwindle = {
    smart_split = false,
    preserve_split = true,
  },

  decoration = {
    rounding = 4,

    active_opacity = 1.0,
    inactive_opacity = 1.0,
    fullscreen_opacity = 1.0,

    dim_inactive = false,
    dim_strength = 0.08,

    blur = {
      enabled = true,
      size = 2,
      passes = 2,
      new_optimizations = true,
      ignore_opacity = true,
      xray = true,
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

hl.device({
  name = "tpps/2-elan-trackpoint",
  sensitivity = 0.2,
})
