# Add env variables that blesh expects
export LANG=en_US.UTF-8
export USER=root

case $- in
  *i*) source /root/.local/share/blesh/ble.sh --noattach;;
    *) return;;
esac

eval "$(fzf --bash)"
export OSH="/root/.oh-my-bash"
OMB_USE_SUDO=true

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

[[ ! ${BLE_VERSION-} ]] || ble-attach
eval "$(starship init bash)"
