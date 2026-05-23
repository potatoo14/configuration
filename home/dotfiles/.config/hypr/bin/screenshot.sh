#!/usr/bin/env bash
# couldn't make this work cleanly in lua
setshader() {
  cmd=$(printf "hl.config({decoration={screen_shader=\"%s\"}})" "$1")
  hyprctl eval "$cmd"
}
setshader ""
grim ${1:+-g "$(slurp -b 110F0D77)"} ~/Archive/"$(date +%y-%m-%d_%H-%M.png)"
setshader "$HOME/.config/hypr/blue-light-filter.glsl"
