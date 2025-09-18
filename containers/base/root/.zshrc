export USER=$(whoami)
export LANG=en_US.UTF-8
export TERM="xterm-256color"
export COLORTERM="truecolor"
export MANPAGER="bat -l man -p"
export STARSHIP_CONFIG="$HOME/.config/starship/zsh.toml"

trap 'echo "\e[32mGoodbye! 👋\e[m"' EXIT

if command -v fzf &> /dev/null; then
  eval "$(fzf --zsh)"
fi

export ZSH="$HOME/.oh-my-zsh"

plugins=(
  git
  fzf
  docker
  docker-compose
  ssh
  mvn
  colored-man-pages
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# Set custom aliases to make the environment nicer to work with.
alias edit="$EDITOR"
alias cat="bat"
alias ls="lsd"
alias grep="rg"
alias find="fd"

eval "$(starship init zsh)"
source "$ZSH/oh-my-zsh.sh"
