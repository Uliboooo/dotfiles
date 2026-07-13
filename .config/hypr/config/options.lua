hl.config({
  general = {
    gaps_in = 2,
    gaps_out = 3,
    border_size = 4,

    layout = "dwindle",
    -- layout = "scrolling",

    col = {
      -- Quiet paper palette: soft sakura focus, opaque rule for inactive windows.
      active_border = "rgb(d38ca0)",
      inactive_border = "rgb(989286)",
    },
  },

  dwindle = {
    smart_split = false,
    preserve_split = true,
  },

  scrolling = {
    -- niri-style resize toggle: cycled with colresize +conf/-conf
    explicit_column_widths = "0.25, 0.333, 0.5",
    follow_focus = true, -- フォーカス移動時にレイアウトが自動スクロール
    follow_min_visible = 0.4, -- ウィンドウの40%以上が見えていれば追従しない
    focus_fit_method = 1, -- 0 = 中央に寄せる, 1 = 画面内に収まるだけ
  },

  decoration = {
    rounding = 0,

    active_opacity = 1.0,
    inactive_opacity = 1.0,
    fullscreen_opacity = 1.0,

    dim_inactive = false,
    -- dim_strength = 0.04,

    blur = {
      enabled = false,
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
