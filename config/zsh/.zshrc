# ~/.zshrc

# Basic Zsh shell options
setopt interactive_comments
setopt AUTO_CD
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select # Use arrow keys to select from tab menu




# Aliases (Same as Bash)
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
alias b='cd ..'
alias ve="source .venv/bin/activate"
alias quick-note="todo quick-note"
alias check="todo check-note"
alias note="todo list-todo"
alias add-todo="todo add-todo"
alias view="kitty +kitten icat"
alias ga="git add -A"
alias gc="git commit -m"
alias push="git push origin main"
alias sz="source home/saven/.config/dotfiles/config/zsh/zshrc"
export LS_COLORS="di=38;5;110:ln=38;5;109:so=38;5;111:pi=38;5;111:ex=38;5;143:bd=38;5;110:cd=38;5;110:or=38;5;167:mi=38;5;167:ow=38;5;110:tw=38;5;110:"

alias ls='ls --color=auto'
alias grep='grep --color=auto'


PROMPT='%n@%m (%D{%k:%M}) [%1~] 󰣇 '
# Colors

# Ensure this is at the top of your file
setopt PROMPT_SUBST

# Define colors as plain strings (no %F inside the variable)
#
# 1. Standard Settings
setopt PROMPT_SUBST
autoload -Uz vcs_info
precmd() { vcs_info }



# --- 2. CORE SETTINGS ---
setopt PROMPT_SUBST
autoload -U compinit; compinit
bindkey -v
export KEYTIMEOUT=1

# --- 3. CURSOR MODE SWITCHING (Block/Line) ---
function zle-keymap-select {
  if [[ $KEYMAP == vicmd ]]; then
    echo -ne '\e[2 q' # Normal: Block
  elif [[ $KEYMAP == main ]] || [[ $KEYMAP == viins ]] || [[ $KEYMAP == "" ]]; then
    echo -ne '\e[5 q' # Insert: Blinking Line
  fi
}
zle -N zle-keymap-select
_fix_cursor() { echo -ne '\e[5 q' }
precmd_functions+=(_fix_cursor)

# --- 4. GIT CONFIG ---
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '%F{$nord_green}%b%f'

# --- 5. SYNTAX HIGHLIGHTING & SUGGESTIONS ---
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# 1. Source the plugin FIRST
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

ZSH_HIGHLIGHT_STYLES[main:command]='fg=#88c0d0'
ZSH_HIGHLIGHT_STYLES[main:alias]='fg=#88c0d0'
ZSH_HIGHLIGHT_STYLES[main:builtin]='fg=#88c0d0'
ZSH_HIGHLIGHT_STYLES[main:function]='fg=#88c0d0'


ZSH_HIGHLIGHT_STYLES[main:single-hyphen-option]='fg=#81a1c1'
ZSH_HIGHLIGHT_STYLES[main:double-hyphen-option]='fg=#81a1c1'




bindkey '^ ' autosuggest-accept

# --- 6. FZF-TAB MENU ---
# Ensure fzf-tab is sourced after compinit
# Using the manual path we setup earlier
[[ -f ~/.zsh/fzf-tab/fzf-tab.zsh ]] && source ~/.zsh/fzf-tab/fzf-tab.zsh
zstyle ':fzf-tab:*' fzf-flags "--color=bg+:#3b4252,bg:#2e3440,spinner:#81a1c1,hl:#616e88,fg:#d8dee9,header:#616e88,info:#b48ead,pointer:#81a1c1,marker:#81a1c1,fg+:#eceff4,prompt:#81a1c1,hl+:#81a1c1"

# --- 7. THE PROMPT ---
# (venv) user @ host (time) [dir] branch glyph


setopt PROMPT_SUBST

# Functions
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

f() {
  local dir
  dir=$(find "${1:-.}" -mindepth 1 \
    \( -path '*/.*' -o -maxdepth 4 \) \
    -type d -print 2> /dev/null | fzf +m) && cd "$dir"
}

jump() {
    local DEST
    if [[ "$1" == "add" ]]; then
        qj add "$2" "${3:-.}"
        return
    fi
    DEST=$(qj jump-dirs "$@")
    if [[ $? -eq 0 && -n "$DEST" ]]; then
        cd "$DEST"
    else
        return 1
    fi
}

# FZF Setup (Zsh specific)
eval "$(fzf --zsh)"
# Source Zsh-specific keybindings (Adjust path if needed, usually in /usr/share/fzf/)
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh

# Keybindings (Zsh bindkey)
# \C = Ctrl, \e = Alt (Escape)
bindkey -s '^f' 'f\n'            # Ctrl-f runs f command
bindkey -s '\ef' 'jump\n'        # Alt-f runs jump
bindkey -s '\er' 'qj jump-files\n' # Alt-r runs qj

# ZLE Widgets for "bind -x" equivalents
# This allows running functions/commands via hotkey
function zle-n() { n; zle reset-prompt }; zle -N zle-n; bindkey '^n' zle-n
function zle-y() { y; zle reset-prompt }; zle -N zle-y; bindkey '^y' zle-y
function zle-quick-note() { quick-note; zle reset-prompt }; zle -N zle-quick-note; bindkey '^o' zle-quick-note
function zle-note() { note; zle reset-prompt }; zle -N zle-note; bindkey '^e' zle-note
function zle-check() { check; zle reset-prompt }; zle -N zle-check; bindkey '^g' zle-check

# Exports
export EDITOR=nvim
export MANPAGER='nvim +Man!'
export ZELLIJ_CONFIG_DIR="$HOME/.config/dotfiles/config/zellij"

# Auto-start Zellij
if [[ -z "$ZELLIJ" ]]; then
    if command -v zellij >/dev/null 2>&1; then
      zellij --session "fresh-$(date +%s)"
    fi
fi

# pnpm
export PNPM_HOME="/home/saven/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

bindkey -v

function zle-keymap-select {
  if [[ $KEYMAP == vicmd ]]; then
    echo -ne '\e[2 q' # Block cursor for Normal Mode
  elif [[ $KEYMAP == main ]] || [[ $KEYMAP == viins ]] || [[ $KEYMAP == "" ]]; then
    echo -ne '\e[5 q' # Blinking line for Insert Mode
  fi
}
zle -N zle-keymap-select

# 3. Ensure the cursor starts as a line when the shell loads
_fix_cursor() { echo -ne '\e[5 q' }
precmd_functions+=(_fix_cursor)

# 4. Optional: Faster switching (reduces the delay when hitting ESC)
export KEYTIMEOUT=1

# Source local bins
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_MIN_BUFFER_SIZE=2
ZSH_AUTOSUGGEST_COMPLETION_IGNORE='(|.*)' 
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


ZSH_HIGHLIGHT_STYLES[command]='fg=#81a1c1'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#81a1c1'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#81a1c1'
ZSH_HIGHLIGHT_STYLES[function]='fg=#81a1c1'

ZSH_HIGHLIGHT_STYLES[string]='fg=#a3be8c'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#a3be8c'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#a3be8c'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#a3be8c'

ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#88c0d0'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#88c0d0'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#d8dee9'

ZSH_HIGHLIGHT_STYLES[path]='fg=#ebcb8b'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#ebcb8b'

ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#3b4252' 
ZSH_HIGHLIGHT_STYLES[bracket]='fg=#eceff4'
ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]='bg=#4c566a'



source ~/.zsh/fzf-tab/fzf-tab.zsh

zstyle ':fzf-tab:*' fzf-flags '--color=bg+:#3b4252,bg:#2e3440,spinner:#81a1c1,hl:#616e88,fg:#d8dee9,header:#616e88,info:#b48ead,pointer:#81a1c1,marker:#81a1c1,fg+:#eceff4,prompt:#81a1c1,hl+:#81a1c1'

zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:list-colors' ${(s.:.)LS_COLORS}

bindkey '^ ' autosuggest-accept


eval "$(starship init zsh)"
