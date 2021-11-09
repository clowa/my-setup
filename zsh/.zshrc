###
# Alias
###

# k8s aliases
alias k=kubectl # generall shortcut
alias kcd='kubectl config set-context $(kubectl config current-context) --namespace ' # quickly change namespace

###
# Homebrew 
###

# Add brew bin to Path environment
BREW_BIN_PATH='/opt/homebrew/bin'
export PATH=$BREW_BIN_PATH:$PATH

###
# Promt
###
eval "$(oh-my-posh --init --shell zsh --config $HOME/github/my-setup/oh-my-posh.omp.json)"

###
# Zsh Plugins
###
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