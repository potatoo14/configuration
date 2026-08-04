#
#  ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# [[ ":$PATH:" != *":$HOME/.npm/bin:"* ]] && PATH="$HOME/.npm/bin:${PATH}"
[[ ":$PATH:" != *":$HOME/.cargo/bin:"* ]] && PATH="$HOME/.cargo/bin:${PATH}"

PS1='\[\e[38;5;114m\]\w\[\e[0m\] \[\e[38;5;230m\]>\[\e[0m\] '

# remove these misterious file that just crop up
rm ~/.bash_history-*.tmp &> /dev/null

# unset HISTFILE
shopt -s dotglob # hidden files exist

# export SYSTEMD_PAGER=
export EDITOR="hx"
export LESSHISTFILE="-"
export NIXPKGS_ALLOW_UNFREE=1

# use color for man pages
export MANPAGER="less -R --use-color -Dd+r -Du+b"
export MANROFFOPT="-P -c"

# flatpak stuff
# export XDG_DATA_DIRS="$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share"

# japanese input engine
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

# please dark theme for everything
export ADW_DEBUG_COLOR_SCHEME=prefer-dark

alias ff='fastfetch'
alias of='onefetch --include-hidden'
alias mobilerun='adb devices && npx expo start --android --localhost'
alias hyprd='hyprctl dispatch'
alias resound='systemctl --user restart pipewire pipewire-pulse wireplumber'
alias cd..='cd ..'
alias sd='systemctl'
alias ls='ls -lha --color=auto'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias less='less --use-color'
alias rm='rm -iv'
alias mv='mv -iv'
alias cp='cp -ivr'
alias mkdir='mkdir -pv'
alias gzip='gzip -v'
alias fd='fd -HE /mnt'
alias nt='nix-tree'
alias ndev='nix develop'
alias gits='git status'
alias gita='git add'
alias gitc='git commit'
alias gitcam='git commit --amend'
alias gitp='git push'
alias gitpf='git push -f'
alias gitpr='git pull --rebase'
alias gitds='git diff --staged'
alias gitd='git diff'
alias gitg='git grep'
alias gitl='git log'
alias gitus='git restore --staged'
alias lsblk='lsblk -f'
alias b='bluetoothctl'
alias uplap='nh os boot -- --option extra-substituters http://192.168.18.4:5000 --option extra-trusted-public-keys local-1://mjrvGM94DuOP9onF4jbICyLmt5RqfFpra+ciY2vsg='
alias sshlap='ssh potato@192.168.18.27'
alias sshpc='ssh user@192.168.18.4'
alias heic2png='magick mogrify -format png *.heic'
alias png2pdf='magick *.png out.pdf'

hyprexec() {
	hyprctl eval "custom_exec({'$*'})"
}

ns() {
	# shellcheck disable=SC2046
	nix shell --impure $(
		for i in "$@"; do
			printf "nixpkgs#%s " "$i"
		done
	)
}
nr() {
	nix run --impure nixpkgs#"$1"
}
ngr() {
	hyprexec "nix run --impure nixpkgs#$1"
}

imgfetch() {
	dir="$HOME/Archive/wallpapers/good taste"

	file=$(find "$dir" -maxdepth 2 -type f | shuf -n 1)
	# img_ratio=$(python -c "print(int($(identify -format "%w/%h*100" "$file")))")
	# [[ "$img_ratio" -gt "140" ]]
	fastfetch -l "$file" --logo-type kitty --logo-height 12

	# rm -f "$dir"/"$file" > /dev/null
}

rvicinae() {
	pgrep vicinae | xargs kill
	hyprexec 'vicinae server'
}

inspectexe() {
	$EDITOR "$(which "$1")"
}

# https://github.com/nix-community/nix-index-database ad-hoc download
download_nixpkgs_cache_index () {
  filename="index-$(uname -m | sed 's/^arm64$/aarch64/')-$(uname | tr "[:upper:]" "[:lower:]")"
  mkdir -p ~/.cache/nix-index && cd ~/.cache/nix-index || exit
  wget -q -N "https://github.com/nix-community/nix-index-database/releases/latest/download/$filename"
  ln -f "$filename" files
}

# auto enter nix-shell when apropriate
[[ -z $DONT_NIX_SHELL ]] && [[ -z $IN_NIX_SHELL ]] && [[ -f ./shell.nix ]] && nix-shell

# fastfetch
