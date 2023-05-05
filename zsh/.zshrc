###
# Alias
###

# k8s aliases
alias k=kubectl # generall shortcut
alias kcd='kubectl config set-context $(kubectl config current-context) --namespace ' # quickly change namespace

# terraform
alias tf=terraform
alias tm=terramate

###
# Homebrew 
###

# Add brew bin to Path environment
BREW_BIN_PATH="$HOMEBREW_REPOSITORY/bin"
export PATH=$BREW_BIN_PATH:$PATH

###
# Promt
###
eval "$(oh-my-posh --init --shell zsh --config $HOME/github/my-setup/oh-my-posh.omp.json)"

###
# Zsh Plugins
###

## Enable zsh syntax highlighting beofore all other plugins to work properly
# See: https://github.com/zsh-users/zsh-history-substring-search
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

## Enable zsh autosuggestions 
# See: https://github.com/zsh-users/zsh-autosuggestions
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#949494"

###
# Shell completion
###

# enable zsh completion
autoload -Uz compinit
compinit

# terramate shell completion
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C $HOMEBREW_REPOSITORY/bin/terramate terramate

# azure cli completion
autoload bashcompinit && bashcompinit
source $HOMEBREW_CELLAR/azure-cli/2.48.1/etc/bash_completion.d/az

###
# Golang
###

GOPATH=$(go env GOPATH)
export PATH="${PATH}:${GOPATH}/bin"

###
# DotNet framework
###

# enable dotnet CLI completion
_dotnet_zsh_complete()
{
  local completions=("$(dotnet complete "$words")")

  reply=( "${(ps:\n:)completions}" )
}

compctl -K _dotnet_zsh_complete dotnet

###
# 1Password
###
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

## 1 Password CLI plugins

# AWS CLI
#source /Users/elliot/.config/op/plugins.sh

###
# Kubernetes
###
export KUBE_EDITOR='code --wait'

# Kubectl plugin manager
export PATH="${PATH}:${HOME}/.krew/bin"

# enable kubectl completion
if [ $commands[kubectl] ]; then
   source <(kubectl completion zsh)
fi

###
# Export binarys
###
export PATH="${PATH}:${HOMEBREW_PREFIX}/opt/sqlite/bin"
export PATH="${PATH}:${HOME}/bin"

# ###
# # Node
# ###
# # Load NVM
# source $(brew --prefix nvm)/nvm.sh
# BREW_NVM_DIR="$(brew --prefix nvm)"
# export NVM_DIR="$HOME/.nvm"
# [ -s "$BREW_NVM_DIR/nvm.sh" ] && . "$BREW_NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$BREW_NVM_DIR/bash_completion" ] && . "$BREW_NVM_DIR/bash_completion"  # This loads nvm bash_completion
