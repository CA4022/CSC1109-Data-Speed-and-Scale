# Add env variables that blesh expects
export LANG=en_US.UTF-8
export USER=root

case $- in
  *i*) source /root/.local/share/blesh/ble.sh --noattach;;
    *) return;;
esac

eval "$(fzf --bash)"
export OSH="/root/.oh-my-bash"
OSH_THEME="axin"
OMB_USE_SUDO=true

completions=(git docker docker-compose ssh)
aliases=(general docker ls)
plugins=(colored-man-pages fzf git)

if ! command -v maven >/dev/null 2>&1; then
    completions+=(maven)
fi

source "$OSH"/oh-my-bash.sh

declare -A edmap
edmap[micro]="micro"
edmap[vim]="vim"
edmap[neovim]="nvim"
edmap[emacs]="emacs"

# Check if EDITOR is already set to a valid choice
if ! [[ "$EDITOR" =~ ^(nvim|vim|emacs|micro)$ ]]; then
    echo ""
    echo "Please select your default text editor:"
    echo "(we recommend micro for those new to working in a CLI)"
    options=("micro" "vim" "neovim" "emacs")
    PS3="Enter a number: "

    select opt in "${options[@]}"; do
        export EDITOR="${edmap[$opt]}"
        echo ""
        echo "✒️ Default editor set to '$EDITOR'."
        break
    done
    unset PS3
fi

# Set terminal env variables
export COLORTERM="truecolor"
export MANPAGER="bat -l man -p "

# Set some aliases to make the env a bit nicer to work with
alias edit=$EDITOR
alias cat="bat"
alias ls="lsd"
alias grep="rg"
alias find="fd"

# Finally, let's print some general and lesson specific orientation text.
echo "
  ____ ____  _ _  ___   ___
 / ___/ ___|/ / |/ _ \\ / _ \\
| |   \\___ \\| | | | | | (_) |
| |___ ___) | | | |_| |\\__, |
 \\____|____/|_|_|\\___/   /_/

"
cat /root/CSS1109.md /lab/lab.md | glow

[[ ! ${BLE_VERSION-} ]] || ble-attach
