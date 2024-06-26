
# Created by `pipx` on 2024-03-20 04:26:54
export PATH="$PATH:/Users/dragon/.local/bin"

eval "$(starship init zsh)"

export EDITOR='nvim'
export HISTSIZE=100000
export SAVEHIST=100000
setopt EXTENDED_HISTORY

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
