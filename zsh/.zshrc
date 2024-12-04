###
# Alias
###

# k8s aliases
alias k=kubectl # generall shortcut
alias kcd='kubectl config set-context $(kubectl config current-context) --namespace ' # quickly change namespace

# terraform
alias tf=terraform
alias tfyolo='terraform apply -auto-approve'
alias tffuckup='terraform destroy -auto-approve'
alias tfdocs='terraform-docs --output-file README.md markdown .'
alias tm=terramate

# macOS aliases
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias rm=trash
fi

# compression
# xz on all cores and 70% of memory
alias xzH='xz -T0 --memory=70%'

###
# Homebrew 
###

# Add brew bin to Path environment
BREW_BIN_PATH="$HOMEBREW_REPOSITORY/bin"
export PATH=$BREW_BIN_PATH:$PATH

###
# Promt
###
eval "$(oh-my-posh init zsh --config $HOME/github/my-setup/oh-my-posh.omp.json)"

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

## Enable zsh openai codex
# See: https://github.com/tom-doerr/zsh_codex

# Check if file ~/.config/openaiapirc exists
if [ -f ~/.config/openaiapirc ]; then
  export ZSH_CUSTOM="$HOME/.zsh"
  source $ZSH_CUSTOM/plugins/zsh_codex/zsh_codex.plugin.zsh
  bindkey '^X' create_completion  

  ## Activate virtual python environment for zsh
  export ZSH_CODEX_PYTHON="$HOME/.zsh/venv/bin/python"

  ## Enable comments in interactive shell mode to allow to instruct AI
  setopt interactive_comments
else
  echo "OpenAI configuration file at ~/.config/openaiapirc does not exist. Skipping zsh_codex plugin."
fi


###
# Shell completion
###

# enable zsh completion
autoload -U +X bashcompinit && bashcompinit
autoload -U +X compinit && compinit
autoload -Uz compinit
compinit

# terraform completion
complete -o nospace -C /opt/homebrew/bin/terraform terraform
# completion for terraform alias
complete -o nospace -C /opt/homebrew/bin/terraform tf

# terramate shell completion
complete -o nospace -C $HOMEBREW_REPOSITORY/bin/terramate terramate

# azure cli completion
if which az &>/dev/null; then
  source $HOMEBREW_CELLAR/azure-cli/*/etc/bash_completion.d/az
else
    echo "Azure CLI is not installed"
fi

# argocd completion
if which argocd &>/dev/null; then
  source <(argocd completion zsh)
  compdef _argocd argocd
else
    echo "ArgoCD CLI is not installed"
fi

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

