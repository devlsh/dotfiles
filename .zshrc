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

# Say hello!
echo "$(<~/name.txt)"
