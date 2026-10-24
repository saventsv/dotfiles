HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"

setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY
setopt AUTO_CD
setopt INTERACTIVE_COMMENTS

alias ls='ls --color=auto'
alias ll='ls -lah'
alias ff='fastfetch'
alias grep='grep --color=auto'

export EDITOR="nvim"
export VISUAL="nvim"
export MANPAGER="nvim +Man!"

# vim binds
bindkey -v
fzf_cd() {
    local dir
    dir=$(fd --type d --max-depth 4 --hidden \
        --exclude .git --exclude .cache 2>/dev/null | fzf)
    if [[ -n "$dir" ]]; then
        cd "$dir"
        zle reset-prompt
    fi
}
zle -N fzf_cd
bindkey '^F' fzf_cd

edit-command-line() {
    zle edit-command-line
}
zle -N edit-command-line
bindkey '^N' edit-command-line

autoload -Uz compinit
compinit
source ~/.local/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh

zstyle ":completion:*" menu select

zstyle ":completion:*" matcher-list 'm:{a-z}={A-Za-z}'

source <(fzf --zsh)

eval "$(zoxide init zsh)"

alias cd='z'
alias cdi='builtin cd'

eval "$(starship init zsh)"

source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^ ' autosuggest-accept

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


# Everforest Dark syntax highlighting
# Place before sourcing zsh-syntax-highlighting

typeset -A ZSH_HIGHLIGHT_STYLES

# Commands
ZSH_HIGHLIGHT_STYLES[command]='fg=#a7c080'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#a7c080'
ZSH_HIGHLIGHT_STYLES[function]='fg=#a7c080'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#a7c080'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#a7c080'

# Command arguments and paths
ZSH_HIGHLIGHT_STYLES[default]='fg=#d3c6aa'
ZSH_HIGHLIGHT_STYLES[path]='fg=#d3c6aa,underline'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#e69875'

# Strings and numbers
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#dbbc7f'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#dbbc7f'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#dbbc7f'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#d699b6'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#e67e80'
ZSH_HIGHLIGHT_STYLES[command-substitution]='fg=#83c092'
ZSH_HIGHLIGHT_STYLES[arithmetic-expansion]='fg=#d699b6'

# Operators and punctuation
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#7fbbb3'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#859289'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg=#83c092'
ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]='fg=#83c092'
ZSH_HIGHLIGHT_STYLES[assign]='fg=#d3c6aa'

# Errors and unknown commands
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#e67e80,bold'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#e69875'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#859289'

PATH="$HOME/.local/bin:$PATH"
