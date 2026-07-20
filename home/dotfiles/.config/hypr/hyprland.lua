-- probably overdone boilerplate reduction but whatever
-- and the lua std is too minimal, would be nice to use luarocks

-- ==========================================
-- UTILITY
-- ==========================================

local SCRIPTS = os.getenv("HOME") .. "/.config/hypr/bin"
local HOST_IS_PC = os.getenv("USER") == "user"

-- function log(txt)
--   hl.notification.create({ text = txt, duration = 10000 })
-- end
function mkScriptRunner(name)
  return function (args)
    return hl.dsp.exec_cmd(string.format("%s/%s %s", SCRIPTS, name, args))
  end
end
function multiBind(keys, bind)
  for _, key in ipairs(keys) do
    hl.bind(key, bind)
  end
end
function batchBind(mod, dispatcher, table)
  for key, val in pairs(table) do
    hl.bind(mod .. "+" .. key, dispatcher(val))
  end
end
function customExec(programs)
  for _, program in ipairs(programs) do
    hl.exec_cmd("uwsm app -- " .. program)
  end
end
function reload()
  hl.exec_cmd("pkill waybar")
  customExec({ "waybar" })
  hl.exec_cmd("hyprctl reload") -- cursed
end

-- ==========================================
-- AUTOSTART
-- ==========================================

hl.on("hyprland.start", function ()
  hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_RUNTIME_DIR")
  customExec({
    "swaync",
    "vicinae server",
    "waybar",
    "fcitx5",
    "easyeffects --gapplication-service",
    "firefox"
  })
  if HOST_IS_PC then
    customExec({"transmission-gtk"})
  end
end)

-- ==========================================
-- ENVIRONMENT VARIABLES
-- ==========================================

function setEnv(vars)
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
  cursor = {
    no_hardware_cursors = true -- to allow tearing
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
function animate(animations)
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
  workspaces = 3,
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
hl.window_rule({
  match = { class = "osu!" },
  immediate = true
})
hl.window_rule({
  match = { class = "ADanceOfFireAndIce" },
  immediate = true
})

-- ==========================================
-- KEYBINDS
-- ==========================================

batchBind(
  "SUPER",
  function (app)
    return hl.dsp.exec_cmd("uwsm app -- " .. app)
  end,
  {
    z = "foot",
    x = "foot btop",
    e = "foot yazi",
    f = "firefox",
    c = "qalculate-gtk",
    g = "easyeffects",
    q = "vicinae toggle"
  }
)

hl.bind("SUPER + grave", hl.dsp.window.close())
hl.bind("SUPER + tab", hl.dsp.layout("togglesplit"))
hl.bind("SUPER + 1", hl.dsp.window.fullscreen())
hl.bind("SUPER + 2", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + 3", hl.dsp.window.pin({ action = "toggle" }))

local dirtable = {
  h = { direction = "left" },
  j = { direction = "down" },
  k = { direction = "up" },
  l = { direction = "right" }
}
batchBind("SUPER", hl.dsp.focus, dirtable)
batchBind("SUPER + SHIFT", hl.dsp.window.move, dirtable)

batchBind("SUPER + CONTROL", hl.dsp.window.resize, {
  h = { x = -50, y = 0, relative = true },
  j = { x = 0, y = 50, relative = true },
  k = { x = 0, y = -50, relative = true },
  l = { x = 50, y = 0, relative = true }
})

-- ==========================================
-- WORKSPACES
-- ==========================================

-- setup the Grid
for i = 1, 6 do
  hl.workspace_rule({ workspace = tostring(i), persistent = true })
end

function move_grid(direction, move_window)
  ---@diagnostic disable-next-line: need-check-nil
  local current_ws = hl.get_active_workspace().id
  local target_ws
  local anim_dir = ""
  local dispatcher = move_window and hl.dsp.window.move or hl.dsp.focus

  -- do some math to figure out which workspace number maps to the grid
  if direction == "right" and current_ws % 3 ~= 0 then
    target_ws = current_ws + 1
    anim_dir = "right"
  elseif direction == "left" and current_ws % 3 ~= 1 then
    target_ws = current_ws - 1
    anim_dir = "left"
  elseif direction == "up" and current_ws > 3 then
    target_ws = current_ws - 3
    anim_dir = "top"
  elseif direction == "down" and current_ws <= 3 then
    target_ws = current_ws + 3
    anim_dir = "bottom"
  else
    return -- we hit an edge, do nothing
  end

  hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 3,
    bezier = "sharp",
    style = "slide " .. anim_dir
  })

  hl.dispatch(dispatcher({ workspace = tostring(target_ws) }))
end

local windowtable = { w = "up", a = "left", s = "down", d = "right" }
-- eager function eval shit on lua
batchBind("SUPER", function (val)
  return function ()
    move_grid(val)
  end
end, windowtable
)
batchBind("SUPER + SHIFT", function (val)
  return function ()
    move_grid(val, true)
  end
end, windowtable
)
hl.bind("SUPER + mouse_up", function ()
  move_grid("right")
end)
hl.bind("SUPER + mouse_down", function ()
  move_grid("left")
end)

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ==========================================
-- MULTIMEDIA & FUNCTION KEYS
-- ==========================================

function mplayer(a)
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

hl.bind("SUPER + ALT + s", reload)
hl.bind("SUPER + ALT + a", hl.dsp.exec_cmd("pkill waybar"))

hl.bind("SUPER + ALT + z", hl.dsp.exec_cmd("roccatsavucontrol -a 1"))
hl.bind("SUPER + ALT + x", hl.dsp.exec_cmd("roccatsavucontrol -a 2"))

-- check tearing in the actual game
hl.bind("SUPER + ALT + tab", hl.dsp.exec_cmd("hyprctl monitors > ~/monitors.txt"))
