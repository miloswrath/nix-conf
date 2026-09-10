-- Resize windows (repeating)
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x = 30,  y = 0   }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.resize({ x = -30, y = 0   }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.resize({ x = 0,   y = -30 }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.resize({ x = 0,   y = 30  }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + l",     hl.dsp.window.resize({ x = 30,  y = 0   }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + h",     hl.dsp.window.resize({ x = -30, y = 0   }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + k",     hl.dsp.window.resize({ x = 0,   y = -30 }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + j",     hl.dsp.window.resize({ x = 0,   y = 30  }), { repeating = true })

-- Move/Resize windows with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Brightness / Volume (repeating)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 2%-"),  { repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set +2%"),  { repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("pamixer -d 2"),            { repeating = true })
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("pamixer -i 2"),            { repeating = true })

-- Media / sleep
hl.bind("xf86Sleep",        hl.dsp.exec_cmd("systemctl suspend"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("pamixer --default-source -t"))
hl.bind("XF86AudioMute",    hl.dsp.exec_cmd("pamixer -t"))
hl.bind("XF86AudioPlay",    hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPause",   hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("xf86AudioNext",    hl.dsp.exec_cmd("playerctl next"))
hl.bind("xf86AudioPrev",    hl.dsp.exec_cmd("playerctl previous"))

-- Keybind help
hl.bind(mainMod .. " + question", hl.dsp.exec_cmd(keybinds))
hl.bind(mainMod .. " + slash",    hl.dsp.exec_cmd(keybinds))
hl.bind(mainMod .. " + CTRL + K", hl.dsp.exec_cmd(keybinds))

-- Autoclicker toggle
hl.bind(mainMod .. " + F8", hl.dsp.exec_cmd(
	"kill $(cat /tmp/auto-clicker.pid) 2>/dev/null || " .. autoclicker .. " --cps 40"
))

-- Night mode
hl.bind(mainMod .. " + F9",  hl.dsp.exec_cmd(hyprsunset .. " --temperature 3500"))
hl.bind(mainMod .. " + F10", hl.dsp.exec_cmd("pkill hyprsunset"))

-- Window / session actions
hl.bind(mainMod .. " + Q",         hl.dsp.exec_cmd(dontkillsteam))
hl.bind("ALT + F4",                hl.dsp.exec_cmd(dontkillsteam))
hl.bind(mainMod .. " + delete",    hl.dsp.exit())
hl.bind(mainMod .. " + W",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.group.toggle())
hl.bind("ALT + return",            hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + ALT + L",   hl.dsp.global("caelestia:lock"))
hl.bind(mainMod .. " + backspace", hl.dsp.exec_cmd("pkill -x wlogout || wlogout -b 4"))
hl.bind("CTRL + ESCAPE",           hl.dsp.exec_cmd("pkill waybar || waybar"))

-- Applications
hl.bind(mainMod .. " + Return",    hl.dsp.exec_cmd(term))
hl.bind(mainMod .. " + T",         hl.dsp.exec_cmd(term))
hl.bind(mainMod .. " + E",         hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + C",         hl.dsp.exec_cmd(editor))
hl.bind(mainMod .. " + F",         hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("spotify"))
hl.bind(mainMod .. " + SHIFT + Y", hl.dsp.exec_cmd("youtube-music"))
hl.bind("CTRL + ALT + DELETE",     hl.dsp.exec_cmd(term .. " -e btop"))
hl.bind(mainMod .. " + CTRL + C",  hl.dsp.exec_cmd("hyprpicker --autocopy --format=hex"))

-- Launchers
-- One bind only: the global dispatcher forwards both press and release to
-- caelestia, which toggles on release. A second release bind toggles twice.
hl.bind(mainMod .. " + A",         hl.dsp.global("caelestia:launcher"), { description = "Launcher" })
hl.bind(mainMod .. " + SPACE",     hl.dsp.exec_cmd("pkill -x rofi || " .. rofi_script .. " drun"))
hl.bind(mainMod .. " + Z",         hl.dsp.exec_cmd("pkill -x rofi || " .. rofi_script .. " emoji"))
hl.bind(mainMod .. " + ALT + K",   hl.dsp.exec_cmd(keyboardswitch))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + G",         hl.dsp.exec_cmd(rofi_script .. " games"))
hl.bind(mainMod .. " + ALT + G",   hl.dsp.exec_cmd(gamemode))
hl.bind(mainMod .. " + V",         hl.dsp.exec_cmd(clipmanager))
hl.bind(mainMod .. " + M",         hl.dsp.exec_cmd("pkill -x rofi || " .. rofimusic))

-- Screenshot
hl.bind(mainMod .. " + P",        hl.dsp.exec_cmd(screenshot .. " s"))
hl.bind(mainMod .. " + CTRL + P", hl.dsp.exec_cmd(screenshot .. " sf"))
hl.bind(mainMod .. " + print",    hl.dsp.exec_cmd(screenshot .. " m"))
hl.bind(mainMod .. " + ALT + P",  hl.dsp.exec_cmd(screenshot .. " p"))

-- NixOS rebuild
hl.bind(mainMod .. " + U", hl.dsp.exec_cmd(term .. " -e " .. rebuild))

-- Cycle windows + bring to top
hl.bind(mainMod .. " + Tab", hl.dsp.window.cycle_next())
hl.bind(mainMod .. " + Tab", hl.dsp.exec_cmd("hyprctl dispatch bringactivetotop"))

-- Focus
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "d" }))
hl.bind("ALT + Tab",           hl.dsp.focus({ direction = "d" }))
hl.bind(mainMod .. " + h",     hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + l",     hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + k",     hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + j",     hl.dsp.focus({ direction = "d" }))

-- Relative workspace switching
hl.bind(mainMod .. " + CTRL + right", hl.dsp.focus({ workspace = "r+1" }))
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.focus({ workspace = "r-1" }))
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.focus({ workspace = "empty" }))

-- Scroll workspaces with mouse wheel
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Mouse side buttons → workspaces 5/6
hl.bind(mainMod .. " + mouse:276",         hl.dsp.focus({ workspace = "5" }))
hl.bind(mainMod .. " + mouse:275",         hl.dsp.focus({ workspace = "6" }))
hl.bind(mainMod .. " + SHIFT + mouse:276", hl.dsp.window.move({ workspace = "5" }))
hl.bind(mainMod .. " + SHIFT + mouse:275", hl.dsp.window.move({ workspace = "6" }))
hl.bind(mainMod .. " + CTRL + mouse:276",  hl.dsp.window.move({ workspace = "5", follow = false }))
hl.bind(mainMod .. " + CTRL + mouse:275",  hl.dsp.window.move({ workspace = "6", follow = false }))

-- Move active window to relative workspace
hl.bind(mainMod .. " + CTRL + ALT + right", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind(mainMod .. " + CTRL + ALT + left",  hl.dsp.window.move({ workspace = "r-1" }))

-- Move active window in tiling layout
hl.bind(mainMod .. " + SHIFT + CTRL + left",  hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + CTRL + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + CTRL + up",    hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + CTRL + down",  hl.dsp.window.move({ direction = "d" }))
hl.bind(mainMod .. " + SHIFT + CTRL + H",     hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + CTRL + L",     hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + CTRL + K",     hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + CTRL + J",     hl.dsp.window.move({ direction = "d" }))

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + CTRL + S", hl.dsp.window.move({ workspace = "special", follow = false }))
hl.bind(mainMod .. " + ALT + S",  hl.dsp.window.move({ workspace = "special", follow = false }))
hl.bind(mainMod .. " + S",        hl.dsp.workspace.toggle_special("special"))

-- Workspaces 1-10
for i = 1, 10 do
	local key = i % 10
	hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
	hl.bind(mainMod .. " + CTRL + " .. key,  hl.dsp.window.move({ workspace = i, follow = false }))
end
