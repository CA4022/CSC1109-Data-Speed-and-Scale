set -x LANG en_US.UTF-8
set -x USER root
set -x COLORTERM "truecolor"
set -x MANPAGER "bat -l man -p"
set -x STARSHIP_CONFIG "/root/.config/starship/fish.toml"

fzf --fish | source

function fish_greeting
end

trap 'echo -e "\e[32mGoodbye! 👋\e[m"' EXIT

if set -q EDITOR
    function edit --description "Alias for launching \$EDITOR with arguments"
        eval $EDITOR $argv
    end
else
    echo "Warning: \$EDITOR environment variable is not set. The 'edit' alias will not work." >&2
end

# Simple aliases for common commands.
alias cat "bat"
alias ls "lsd"
alias grep "rg"
alias find "fd"

starship init fish | source
