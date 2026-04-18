#
# ~/.bash_profile
#

# run bashrc first to setup the environment
[[ -f ~/.bashrc ]] && . ~/.bashrc

# use uwsm startup instead
if uwsm check may-start; then
    exec uwsm start start-hyprland
fi

# only run hyprland if no other instances are running
# [[ $(pgrep Hyprland) ]] || Hyprland
