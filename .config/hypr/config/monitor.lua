hl.monitor({
  output = "eDP-1",
  mode = "1920x1200",
  position = "320x1440",
  scale = 1,
})

hl.monitor({
  output = "DP-1",
  mode = "3840x2160",
  position = "0x0",
  scale = 1.5,
})

hl.monitor({
  output = "HDMI-A-1",
  mode = "3840x2160",
  position = "0x0",
  scale = 1.5,
  mirror = "DP-1",
})
