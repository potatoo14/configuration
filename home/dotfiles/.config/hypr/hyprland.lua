-- probably overdone boilerplate reduction but whatever
-- and the lua std is too minimal, would be nice to use luarocks

-- ==========================================
-- VARIABLES & UTILITY FUNCTIONS
-- ==========================================

local SCRIPTS = os.getenv("HOME") .. "/.config/hypr/bin"

local function mkScriptRunner(name)
  return function (args)
    return hl.dsp.exec_cmd(string.format("%s/%s %s", SCRIPTS, name, args))
  end
end

local function multiBind(keys, bind)
  for _, key in ipairs(keys) do
    hl.bind(key, bind)
  end
end

-- ==========================================
-- AUTOSTART
-- ==========================================

local function multiExec(programs)
  for _, program in ipairs(programs) do
    hl.exec_cmd("uwsm app -- " .. program)
  end
end
hl.on("hyprland.start", function ()
  hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_RUNTIME_DIR")
  multiExec({
    "swaync",
    "vicinae server",
    "waybar",
    "fcitx5",
    "easyeffects --gapplication-service"
  })
end)

-- ==========================================
-- ENVIRONMENT VARIABLES
-- ==========================================

local function setEnv(vars)
  for key, val in pairs(vars) do
    hl.env(key, val)
  end
end
setEnv({
  XDG_CURRENT_DESKTOP = "Hyprland",
  QT_QPA_PLATFORMTHEME = "qt5ct",
  DXVK_CONFIG_FILE = "/home/user/.config/dxvk.conf",
  BROWSER = "firefox",
  GDK_BACKEND = "wayland,x11,*",
  QT_QPA_PLATFORM = "wayland;xcb"
})

-- ==========================================
-- CORE CONFIGURATION
-- ==========================================

hl.config({
  general = {
    gaps_in = 0,
    gaps_out = 0,
    border_size = 0,
    layout = "dwindle",
    allow_tearing = true
  },
  decoration = {
    rounding = 10,
    screen_shader = "~/.config/hypr/blue-light-filter.glsl"
  },
  debug = {
    damage_tracking = 0 -- fix shader refresh, it's a shit fix, i know
  },
  dwindle = {
    preserve_split = true
  },
  misc = {
    disable_hyprland_logo = true,
    enable_anr_dialog = false
  },
  input = {
    kb_options = "caps:hyper",
    repeat_delay = 160,
    repeat_rate = 120,
    touchpad = {
      disable_while_typing = false,
      natural_scroll = true
    }
  },
  ecosystem = {
    no_update_news = true,
    no_donation_nag = true
  }
})

for i = 1, 2 do -- idk why my mouse do this
  hl.device({
    name = "roccat-roccat-savu-" .. i,
    sensitivity = -0.79
  })
end

-- ==========================================
-- ANIMATIONS
-- ==========================================

hl.curve("sharp", { type = "bezier", points = { { 0, 0.9 }, { 0, 1.0 } } })
local function animate(animations)
  for leaf, val in pairs(animations) do
    -- If val is a table, extract [1] and [2]. Otherwise, val is just the speed.
    local speed = type(val) == "table" and val[1] or val
    local style = type(val) == "table" and val[2] or nil

    hl.animation({
      leaf = leaf,
      enabled = true,
      speed = speed,
      bezier = "sharp",
      style = style
    })
  end
end
animate({
  windows = 4,
  windowsOut = 5,
  border = 7,
  borderangle = 6,
  fade = 5,
  workspaces = 4,
  specialWorkspace = { 4, "slidevert" }
})

-- ==========================================
-- WINDOW RULES
-- ==========================================

hl.window_rule({
  name = "calculator",
  match = { class = "qalculate-gtk" },
  float = true,
  center = true
})
hl.window_rule({
  name = "transmission",
  match = { title = "Transmission" },
  float = true,
  center = true
})

-- ==========================================
-- KEYBINDS
-- ==========================================

local function bindApps(binds)
  for key, app in pairs(binds) do
    hl.bind("SUPER +" .. key, hl.dsp.exec_cmd("uwsm app -- " .. app))
  end
end
bindApps({
  s = "foot",
  a = "foot btop",
  e = "foot yazi",
  f = "firefox",
  c = "qalculate-gtk",
  d = "easyeffects",
  w = "vicinae toggle",
  t = "transmission-gtk"
})

hl.bind("SUPER + q", hl.dsp.window.close())
hl.bind("SUPER + grave", hl.dsp.window.fullscreen())
hl.bind("MOD3 + grave", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + tab", hl.dsp.layout("togglesplit"))

local function bindDirs(mod, dispatcher, dirTable)
  for key, val in pairs(dirTable) do
    hl.bind(mod .. "+" .. key, dispatcher(val))
  end
end

local dirtable = {
  h = { direction = "left" },
  j = { direction = "down" },
  k = { direction = "up" },
  l = { direction = "right" }
}
bindDirs("SUPER", hl.dsp.focus, dirtable)
bindDirs("SUPER + SHIFT", hl.dsp.window.move, dirtable)

local coordtable = {
  h = { x = -50, y = 0, relative = true },
  j = { x = 0, y = 50, relative = true },
  k = { x = 0, y = -50, relative = true },
  l = { x = 50, y = 0, relative = true }
}
bindDirs("SUPER + CONTROL", hl.dsp.window.resize, coordtable)

-- ==========================================
-- WORKSPACES
-- ==========================================

for i = 1, 10 do
  local key = i % 10 -- 10 maps to key 0
  hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind("SUPER + d", hl.dsp.workspace.toggle_special("sound"))

multiBind({ "SUPER + x", "SUPER + mouse_up" }, hl.dsp.focus({ workspace = "r+1" }))
multiBind({ "SUPER + z", "SUPER + mouse_down" }, hl.dsp.focus({ workspace = "r-1" }))
multiBind({ "SUPER + SHIFT + x", "SUPER + SHIFT + mouse_up" }, hl.dsp.window.move({ workspace = "r+1" }))
multiBind({ "SUPER + SHIFT + z", "SUPER + SHIFT + mouse_down" }, hl.dsp.window.move({ workspace = "r-1" }))

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ==========================================
-- MULTIMEDIA & FUNCTION KEYS
-- ==========================================

local function mplayer(a)
  return hl.dsp.exec_cmd("playerctl " .. a)
end
multiBind({ "XF86AudioPlay", "MOD3 + 1" }, mplayer("play-pause"))
multiBind({ "XF86AudioPrev", "MOD3 + 2" }, mplayer("previous"))
multiBind({ "XF86AudioNext", "MOD3 + 3" }, mplayer("next"))
multiBind({ "XF86AudioMute", "MOD3 + f" }, hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))

local vol = mkScriptRunner("volume.sh")
multiBind({ "XF86AudioRaiseVolume", "MOD3 + d" }, vol("+"))
multiBind({ "XF86AudioLowerVolume", "MOD3 + s" }, vol("-"))

local bri = mkScriptRunner("brightness.sh")
multiBind({ "XF86MonBrightnessUp", "MOD3 + e" }, bri("+"))
multiBind({ "XF86MonBrightnessDown", "MOD3 + w" }, bri("-"))

-- ==========================================
-- SYSTEM, SHADERS & UTILITIES
-- ==========================================

-- looks cursed, but bash is just this convinient
local toggle_ja = [[
if [ "$(fcitx5-remote -n)" = "mozc" ]; then
  fcitx5-remote -s keyboard-us
  else fcitx5-remote -s mozc
fi
]]
local toggle_intl = [[
if [ "$(fcitx5-remote -n)" = "keyboard-us-intl" ]; then
  fcitx5-remote -s keyboard-us
  else fcitx5-remote -s keyboard-us-intl
fi
]]
hl.bind("MOD3 + q", hl.dsp.exec_cmd(toggle_ja))
hl.bind("MOD3 + a", hl.dsp.exec_cmd(toggle_intl))

local scrs = mkScriptRunner("screenshot.sh")
hl.bind("SHIFT + print", scrs("select_mode"))
hl.bind("print", scrs(""))

local shader = mkScriptRunner("shader.py")
hl.bind("MOD3 + x", shader("+"))
hl.bind("MOD3 + z", shader("-"))

hl.bind("MOD3 + SUPER + q", hl.dsp.exec_cmd("hyprpicker -a"))

hl.bind(
  "SUPER + ALT + s",
  hl
    .dsp
    .exec_cmd("pkill waybar; hyprctl eval 'hl.exec_cmd(\"uwsm app -- waybar\")'; hyprctl reload") -- cursed
)
hl.bind("SUPER + ALT + a", hl.dsp.exec_cmd("pkill waybar"))

hl.bind("SUPER + ALT + z", hl.dsp.exec_cmd("roccatsavucontrol -a 1"))
hl.bind("SUPER + ALT + x", hl.dsp.exec_cmd("roccatsavucontrol -a 2"))
