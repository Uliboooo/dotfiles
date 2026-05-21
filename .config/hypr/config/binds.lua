hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + T", hl.dsp.exec_cmd("kitty"))
hl.bind("SUPER + M", hl.dsp.exit(), { locked = true })
hl.bind("SUPER + E", hl.dsp.exec_cmd("kitty -e yazi ."))
hl.bind("SUPER + V", hl.dsp.window.float())
hl.bind("SUPER + D", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ "fullscreen", "toggele" }))
hl.bind("SUPER + J", hl.dsp.layout("togglesplit"))

-- hl.bind("CONTROL + BackSpace", hl.dsp.send_shortcut({ mods = "", key = "Delete" }))

-- Move focus with mainMod + arrow keys)
hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }))

hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e+1" }))

-- Switch workspaces with mainMod + [0-9])
hl.bind("SUPER + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind("SUPER + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind("SUPER + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind("SUPER + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind("SUPER + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind("SUPER + 6", hl.dsp.focus({ workspace = 6 }))
hl.bind("SUPER + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind("SUPER + 8", hl.dsp.focus({ workspace = 8 }))
hl.bind("SUPER + 9", hl.dsp.focus({ workspace = 9 }))
hl.bind("SUPER + 0", hl.dsp.focus({ workspace = 10 }))

-- Move active window to a workspace with mainMod + SHIFT + [0-9])

hl.bind("SUPER + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind("SUPER + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind("SUPER + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind("SUPER + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))
hl.bind("SUPER + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }))
hl.bind("SUPER + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }))
hl.bind("SUPER + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }))
hl.bind("SUPER + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }))
hl.bind("SUPER + SHIFT + 9", hl.dsp.window.move({ workspace = 9 }))
hl.bind("SUPER + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- swap windows
hl.bind("SUPER + SHIFT + H", hl.dsp.window.swap({ direction = "left" }))
hl.bind("SUPER + SHIFT + L", hl.dsp.window.swap({ direction = "right" }))

-- screenshot
-- active window
hl.bind("PRINT", hl.dsp.exec_cmd("hyprshot -m window -m active --freeze"), { locked = true })
hl.bind("SUPER + P", hl.dsp.exec_cmd("hyprshot -m window -m active --freeze"), { locked = true })
-- region
hl.bind("CONTROL + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region --freeze"), { locked = true })
-- output
hl.bind(
  "SUPER + PRINT",
  hl.dsp.exec_cmd("hyprshot -m output -m active --freeze"),
  { locked = true }
)
hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("sh ~/dotfiles/commands/cmd_p.py"))

-- toggle msg ws
-- bind = SUPER, S, togglespecialworkspace, Msg
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("MSG"))
hl.bind("SUPER + SHIFT + S", hl.dsp.window.move({ workspace = "special:MSG" }))

hl.bind("SUPER + backslash", hl.dsp.workspace.toggle_special("SCR"))
hl.bind("SUPER + SHIFT + backslash", hl.dsp.window.move({ workspace = "special:SCR" }))

-- wallpapers
hl.bind("SUPER + W", hl.dsp.exec_cmd("ysh ~/dotfiles/script/cycle_wallpaper.ysh 'seq'"))
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("ysh ~/dotfiles/script/cycle_wallpaper.ysh 'rev'"))
-- video wallpaper
hl.bind("ALT + W", hl.dsp.exec_cmd("ysh ~/dotfiles/script/cycle_wallpaper.ysh 'vdo'"))
-- safe wallpaper
hl.bind("SUPER + ALT + W", hl.dsp.exec_cmd("ysh ~/dotfiles/script/safe_wallpaper.ysh"))

-- Immediately lock
-- bind = SUPER SHIFT, E, exec, ~/dotfiles/commands/logout.py
hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd("~/dotfiles/commands/logout.py"))

-- cliphist
hl.bind(
  "SUPER + SHIFT + V",
  hl.dsp.exec_cmd("cliphist list | rofi -dmenu -p ' ' | cliphist decode | wl-copy")
)

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ラップトップ マルチメディアキー（音量・輝度）
-- bindel = repeating + locked → { repeating = true, locked = true }
hl.bind(
  "XF86AudioRaiseVolume",
  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 3%+"),
  { repeating = true, locked = true }
)
hl.bind(
  "XF86AudioLowerVolume",
  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%-"),
  { repeating = true, locked = true }
)
hl.bind(
  "XF86AudioMute",
  hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
  { repeating = true, locked = true }
)
hl.bind(
  "XF86AudioMicMute",
  hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
  { repeating = true, locked = true }
)
hl.bind(
  "XF86MonBrightnessUp",
  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 3%+"),
  { repeating = true, locked = true }
)
hl.bind(
  "XF86MonBrightnessDown",
  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 3%-"),
  { repeating = true, locked = true }
)
-- hl.bind("XF86LinkPhone", hl.dsp.workspace.change({ delta = 1 }), { repeating = true, locked = true })

-- playerctl（bindl = locked のみ）
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86Favorites", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("SUPER + K", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

-- 蓋スイッチ
hl.bind(
  "switch:on:Lid Switch",
  hl.dsp.exec_cmd("~/.config/hypr/handle_lid.sh close"),
  { locked = true }
)
hl.bind(
  "switch:off:Lid Switch",
  hl.dsp.exec_cmd("~/.config/hypr/handle_lid.sh open"),
  { locked = true }
)

-- リサイズモード（submap）
hl.bind("SUPER + R", hl.dsp.submap("resize"))

hl.define_submap("resize", function()
  hl.bind("H", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
  hl.bind("L", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
  hl.bind("K", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
  hl.bind("J", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })
  hl.bind("escape", hl.dsp.submap("reset"))
end)
