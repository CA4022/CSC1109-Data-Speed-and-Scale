# Add env variables that blesh expects
export LANG=en_US.UTF-8
export STARSHIP_CONFIG="~/.config/starship/bash.toml"

case $- in
  *i*) source ~/.local/share/blesh/ble.sh --noattach;;
    *) return;;
esac

eval "$(fzf --bash)"
export OSH="~/.oh-my-bash"

completions=(git docker docker-compose maven ssh)
aliases=(general docker ls)
plugins=(colored-man-pages fzf git)

source "$OSH"/oh-my-bash.sh

# Set terminal env variables
export COLORTERM="truecolor"
export MANPAGER="bat -l man -p "

# Set some aliases to make the env a bit nicer to work with
alias edit=$EDITOR
alias cat="bat"
alias ls="lsd"
alias grep="rg"
alias find="fd"

eval "$(starship init bash)"

[[ ! ${BLE_VERSION-} ]] || ble-attach
