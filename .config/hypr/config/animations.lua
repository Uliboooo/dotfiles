hl.curve("expo", { type = "bezier", points = { { 0.16, 1.0 }, { 0.3, 1.0 } } })
hl.curve("back", { type = "bezier", points = { { 0.34, 1.56 }, { 0.64, 1.0 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1.0, 1.0 } } })
hl.curve("snap", { type = "bezier", points = { { 0.19, 1.0 }, { 0.22, 1.0 } } })

hl.animation({
  leaf = "windows",
  enabled = true,
  speed = 3,
  bezier = "expo",
  style = "popin 70%",
})
hl.animation({
  leaf = "windowsOut",
  enabled = true,
  speed = 1.5,
  bezier = "snap",
  style = "popin 90%",
})
hl.animation({ leaf = "windowsMove", enabled = true, speed = 1.5, bezier = "snap" })
hl.animation({ leaf = "border", enabled = true, speed = 2, bezier = "linear" })
hl.animation({ leaf = "fade", enabled = true, speed = 1.5, bezier = "snap" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 1.5, bezier = "snap" })
hl.animation({
  leaf = "workspaces",
  enabled = true,
  speed = 1.5,
  bezier = "snap",
  style = "slide",
})
hl.animation({
  leaf = "specialWorkspace",
  enabled = true,
  speed = 1.5,
  bezier = "snap",
  style = "slidevert",
})
hl.animation({ leaf = "fadeLayers", enabled = true, speed = 1.5, bezier = "snap" })
