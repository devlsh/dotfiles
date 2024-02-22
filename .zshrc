export ZSH="$HOME/.oh-my-zsh"
export EDITOR="nano"
export GPG_TTY=$(tty)

ZSH_THEME="avit"

plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh
source $HOME/.aliases

# Load fnm
eval "$(fnm env --use-on-cd)"

# Fix for SSH over kitty
[ "$TERM" = "xterm-kitty" ] && alias ssh="kitty +kitten ssh"

# Say hello!
echo "$(<~/name.txt)"
