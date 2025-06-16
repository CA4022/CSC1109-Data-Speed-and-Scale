set -x LANG en_US.UTF-8
set -x USER root
set -x COLORTERM "truecolor"
set -x MANPAGER "bat -l man -p"

fzf --fish | source

if set -q EDITOR
    function edit --description "Alias for launching \$EDITOR with arguments"
        eval $EDITOR $argv
    end
else
    echo "Warning: \$EDITOR environment variable is not set. The 'edit' alias will not work." >&2
end

# Simple aliases for common commands.
alias cat "bat" # Use bat as a cat replacement
alias ls "lsd"                   # Use lsd for listings
alias grep "rg"                  # Use ripgrep for searching
alias find "fd"                  # Use fd for finding files

starship init fish | source
