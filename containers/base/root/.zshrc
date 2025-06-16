export LANG=en_US.UTF-8
export USER=root
export COLORTERM="truecolor"
export MANPAGER="bat -l man -p"

export ZSH="$HOME/.oh-my-zsh"

plugins=(
  git
  fzf
  sudo
  docker
  docker-compose
  ssh
  mvn
  colored-man-pages
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

if command -v fzf &> /dev/null; then
  eval "$(fzf --zsh)"
fi

# Set custom aliases to make the environment nicer to work with.
alias edit="$EDITOR" # Assumes $EDITOR is set, e.g., export EDITOR=vim
alias cat="bat"      # Use 'bat' for viewing files with syntax highlighting
alias ls="lsd"       # Use 'lsd' for a more modern 'ls' command
alias grep="rg"      # Use 'ripgrep' for a faster 'grep'
alias find="fd"      # Use 'fd' for a simpler and faster 'find'

eval "$(starship init zsh)"
