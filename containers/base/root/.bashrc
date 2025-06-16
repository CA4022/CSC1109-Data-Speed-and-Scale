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

completions=(git docker docker-compose ssh)
aliases=(general docker ls)
plugins=(colored-man-pages fzf git)

if ! command -v maven >/dev/null 2>&1; then
    completions+=(maven)
fi

source "$OSH"/oh-my-bash.sh

declare -A edmap
edmap[micro μ]="micro"
edmap[vim ]="vim"
edmap[neovim ]="nvim"
edmap[emacs ]="emacs"

# Check if EDITOR is already set to a valid choice
if ! [[ "$EDITOR" =~ ^(nvim|vim|emacs|micro)$ ]]; then
    echo ""
    echo -e "\033[90m\033[0m Please select your default text editor:"
    echo "(we recommend micro for those new to working in a CLI)"
    options=("micro μ" "vim " "neovim " "emacs ")
    PS3="Enter a number: "

    select opt in "${options[@]}"; do
        export EDITOR="${edmap[$opt]}"
        echo ""
        echo -e "\033[34m\033[0m Default editor set to '$EDITOR'."
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
echo -e "
\033[35m .o88b. .d8888.  .o88b.  db  db  .d88b.  .d888b.
d8P  Y8 88'  YP d8P  Y8 o88 o88 .8P  88. 88' \`8D
8P      \`8bo.   8P       88  88 88  d'88 \`V8o88'
8b        \`Y8b. 8b       88  88 88 d' 88    d8'
Y8b  d8 db   8D Y8b  d8  88  88 \`88  d8'   d8'
 \`Y88P' \`8888Y'  \`Y88P'  VP  VP  \`Y88P'   d8'\033[0m"
cat /root/CSS1109.md /lab/lab.md | glow

[[ ! ${BLE_VERSION-} ]] || ble-attach
eval "$(starship init bash)"
