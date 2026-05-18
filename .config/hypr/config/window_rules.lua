-- # pip
-- windowrulev = float, title:^(Picture-in-Picture)$
-- windowrulev = pin, title:^(Picture-in-Picture)$
-- windowrulev = noinitialfocus, title:^(Picture-in-Picture)$
--

hl.window_rule({
  name = "dev-float",
  match = {
    title = "^(dev-float)$",
  },
  size = { "(monitor_w*0.75)", "(monitor_h*0.9)" },
  float = true,
  center = true,
})

hl.window_rule({
  name = "dev-float-by-class",
  match = {
    class = "^(dev-float)$",
  },
  size = { "(monitor_w*0.75)", "(monitor_h*0.9)" },
  float = true,
  center = true,
})


-- hl.window_rule({
--   name = "pip",
--   match = {
--     title = "^(Picture-in-Picture)$",
--     class = "^(Picture-in-Picture)$",
--   },
--   float = true,
--   no_initial_focus = true,
--   pin = true,
-- })
