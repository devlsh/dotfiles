export ZSH="$HOME/.oh-my-zsh"
export GPG_TTY=$(tty)
export EDITOR="nano"

ZSH_THEME="avit"

plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# load alias helpers
source $HOME/.aliases

# shhhh
if [[ -e $HOME/.secrets ]]; then
  source $HOME/.secrets
fi

# load fnm
FNM_PATH="$HOME/.local/share/fnm"

if [ -d "$FNM_PATH" ]; then
  export PATH="$HOME/.local/share/fnm:$PATH"
  eval "$(fnm env)"
fi

# fix for ssh inside kitty
[ "$TERM" = "xterm-kitty" ] && alias ssh="kitty +kitten ssh"

# hi!
echo "$(<~/name.txt)"
