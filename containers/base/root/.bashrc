# Set terminal env variables
export STARSHIP_CONFIG="$HOME/.config/starship/bash.toml"
export TERM="xterm-256color"
export COLORTERM="truecolor"
export MANPAGER="bat -l man -p "

# Set some aliases to make the env a bit nicer to work with
alias edit=$EDITOR
alias cat="bat"
alias ls="lsd"
alias grep="rg"
alias find="fd"

eval "$(starship init bash)"

[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
    . /usr/share/bash-completion/bash_completion
