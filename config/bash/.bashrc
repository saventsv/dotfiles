#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ll='ls -la'
alias n='nvim'
alias i='sudo pacman -S'
alias a='yay -S'
alias r='sudo pacman -Rcns'
alias ar='yay -Rns'
alias s='pacman -Ss'
alias as='yay -Ss'
alias au='yay -Syu'
alias u='sudo pacman -Syu'
alias cman='man 3'
PS1='[\u@\h \W]\$ '
PS1='\u@\h (\A) [\W] 󰣇 '

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

eval "$(fzf --bash)"

source /usr/share/fzf/key-bindings.bash
source /usr/share/fzf/completion.bash

#f() {
#  local dir
#  dir=$(find ${1:-.} -path '*/.*' -prune -o -type d 2> /dev/null | fzf +m) && cd "$dir"
#}

f() {
  local dir
  dir=$(find "${1:-.}" -mindepth 1 \
    \( -path '*/.*' -o -maxdepth 4 \) \
    -type d -print 2> /dev/null | fzf +m) && cd "$dir"
}


bind '"\C-f": "\C-uf\C-m"'
bind -x '"\C-n": n'
bind -x '"\C-y": y'

export EDITOR=nvim
export MANPAGER='nvim +Man!'

