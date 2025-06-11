case $- in
  *i*) ;;
    *) return;;
esac

export OSH='/root/.oh-my-bash'
OSH_THEME="axin"
OMB_USE_SUDO=true

completions=(git docker docker-compose ssh)
aliases=(general docker ls)
plugins=(colored-man-pages fzf git)

if ! command -v maven >/dev/null 2>&1; then
    completions+=(maven)
fi

source "$OSH"/oh-my-bash.sh

if ! [[ "$EDITOR" =~ ^(vim|emacs|micro)$ ]]; then
    echo "Please select your default text editor:"
    # Defines the list of editor choices.
    options=("micro" "neovim" "emacs" "Skip")

    # The 'select' command creates an interactive menu from the options.
    select opt in "${options[@]}"
    do
        case $opt in
            "micro")
                if command -v micro &> /dev/null; then
                    export EDITOR=micro
                    echo "Default editor set to 'micro'."
                else
                    echo "Error: 'micro' is not installed. Please install it to use it as the default."
                fi
                break
                ;;
            "neovim")
                if command -v nvim &> /dev/null; then
                    export EDITOR=nvim
                    echo "Default editor set to 'neovim'."
                else
                    echo "Error: 'neovim' is not installed. Please install it to use it as the default."
                fi
                break
                ;;
            "emacs")
                if command -v emacs &> /dev/null; then
                    export EDITOR=emacs
                    echo "Default editor set to 'emacs'."
                else
                    echo "Error: 'emacs' is not installed. Please install it to use it as the default."
                fi
                break
                ;;
            "Skip")
                echo "No default editor has been set for this session."
                break
                ;;
            *)
                echo "Invalid option $REPLY. Please enter the number corresponding to your choice."
                ;;
        esac
    done
fi
