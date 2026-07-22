hl.env("MOZ_ENABLE_WAYLAND", "1")
-- GDK_BACKEND はここで設定しないこと。dbus-update-activation-environment 経由で
-- systemd --user に伝播し、xdg-desktop-portal-gnome の display server 互換チェックを
-- 落として settings only モードにしてしまう (FileChooser / ScreenCast が消え、
-- Firefox のファイル選択が "No such interface org.freedesktop.impl.portal.FileChooser"
-- で死ぬ)。さらに一度入ると systemd --user 環境に残り、次に niri セッションへ
-- 入っても効き続ける。GTK は WAYLAND_DISPLAY があれば自動で wayland を選ぶので不要。
-- 同じ注意書きが .config/niri/config.kdl の environment ブロックにもある。

hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "Wayland")
hl.env("XCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("XCURSOR_SIZE", "20")

local desktop = os.getenv("XDG_DESKTOP_DIR") or (os.getenv("HOME") .. "/Desktop/")

hl.env("HYPRSHOT_DIR", desktop)

hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

hl.env("GTK_USE_PORTAL", "1")
