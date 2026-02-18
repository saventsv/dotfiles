# ~/.zshrc

# Basic Zsh shell options
setopt interactive_comments
setopt AUTO_CD
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select # Use arrow keys to select from tab menu

export COLORTERM=truecolor
export TERM=xterm-256color

# Aliases (Same as Bash)
alias ll='eza -lh --icons --git --group-directories-first --color=always'
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
alias d="deactivate"
alias quick-note="todo quick-note"
alias check="todo check-note"
alias note="todo list-todo"
alias add-todo="todo add-todo"
alias view="kitty +kitten icat"
alias ga="git add -A"
alias gs="git status"
alias push="git push origin main"
alias sz="source /home/saven/.config/dotfiles/config/zsh/zshrc"
alias quick="quick-check"

alias ls='exa --icons --git --group-directories-first --color=always'
alias grep='grep --color=auto'

export COLORTERM=truecolor

if command -v vivid >/dev/null 2>&1; then
    export LS_COLORS="$(vivid generate nord)"
    export EZA_COLORS="reset" 
fi

export EZA_COLORS="\
ur=38;2;163;190;140:uw=38;2;163;190;140:ux=38;2;191;97;106:\
sn=38;2;235;203;139:sb=38;2;235;203;139:\
da=38;2;94;129;172:\
uu=38;2;235;203;139:gu=38;2;235;203;139:\
ln=38;2;136;192;208:lp=38;2;136;192;208:lc=38;2;136;192;208:xx=38;2;136;192;208:\
or=38;2;191;97;106:\
hd=1;38;2;94;129;172"

auto_ls_nord() {
    if [[ -r $PWD ]]; then
        eza --icons --git --group-directories-first --color=always
    fi
}

autoload -U add-zsh-hook
add-zsh-hook chpwd auto_ls_nord

autoload -U add-zsh-hook

# Auto-ls when changing directories
# chpwd() { 
    # emulate -L zsh 
    # ls  --color=auto  
# } 


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

export ABBR_QUIETER=1
source /usr/share/zsh/plugins/zsh-abbr/zsh-abbr.zsh

ABBR_SET_EXPANSION_CURSOR=1
abbr add gc='git commit -m "%"'

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

j() {
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
bindkey -s '\ef' 'j\n'        # Alt-f runs jump
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
export NOTES_DIR="/home/saven/Notes/"
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



export KEYTIMEOUT=1              # Removes the lag when hitting ESC

# --- 2. CURSOR VISUAL FEEDBACK ---
# Changes cursor to 'Bar' for Insert and 'Block' for Normal
function zle-keymap-select {
  case $KEYMAP in
    vicmd)      echo -ne '\e[2 q' ;; # Block
    viins|main) echo -ne '\e[5 q' ;; # Beam
  esac
}
zle -N zle-keymap-select
_fix_cursor() { echo -ne '\e[5 q' }
precmd_functions+=(_fix_cursor)


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


_zsh_autosuggest_strategy_valid_command() {
    local suggestion=$1
    local cmd=${suggestion%% *} 
    if (( $+commands[$cmd] || $+aliases[$cmd] || $+functions[$cmd] )); then
        typeset -g suggestion=$suggestion
    else
        unset suggestion
    fi
}


export ZSH_AUTOSUGGEST_STRATEGY=(history completion valid_command)
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_MIN_BUFFER_SIZE=2
ZSH_AUTOSUGGEST_COMPLETION_IGNORE='(|.*)' 
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:*' completer _complete _ignored _approximate



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

ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#b48ead' 
ZSH_HIGHLIGHT_STYLES[bracket]='fg=#eceff4'
ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]='bg=#4c566a'


autoload -U predict-on
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 
zstyle ':completion:*' list-grouped true

source ~/.zsh/fzf-tab/fzf-tab.zsh

zstyle ':fzf-tab:*' fzf-flags '--color=bg+:#3b4252,bg:#2e3440,spinner:#81a1c1,hl:#616e88,fg:#d8dee9,header:#616e88,info:#b48ead,pointer:#81a1c1,marker:#81a1c1,fg+:#eceff4,prompt:#81a1c1,hl+:#81a1c1'

zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:list-colors' ${(s.:.)LS_COLORS}

bindkey '^ ' autosuggest-accept


eval "$(starship init zsh)"

export PATH="$HOME/.cargo/bin:$PATH"
