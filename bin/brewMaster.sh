#! /bin/bash
cat << EOF
██████╗ ██████╗ ███████╗██╗    ██╗    ███╗   ███╗ █████╗ ███████╗████████╗███████╗██████╗ 
██╔══██╗██╔══██╗██╔════╝██║    ██║    ████╗ ████║██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗
██████╔╝██████╔╝█████╗  ██║ █╗ ██║    ██╔████╔██║███████║███████╗   ██║   █████╗  ██████╔╝
██╔══██╗██╔══██╗██╔══╝  ██║███╗██║    ██║╚██╔╝██║██╔══██║╚════██║   ██║   ██╔══╝  ██╔══██╗
██████╔╝██║  ██║███████╗╚███╔███╔╝    ██║ ╚═╝ ██║██║  ██║███████║   ██║   ███████╗██║  ██║
╚═════╝ ╚═╝  ╚═╝╚══════╝ ╚══╝╚══╝     ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝
EOF
echo 'Updating brew ...'
brew update > /dev/null

echo 'Outdated packages:'
brew outdated --quiet

echo 'Upgrading packages ...'
brew upgrade

echo 'Upgrading casks ...'
brew upgrade --cask

echo 'Cleanup ...'
brew autoremove && brew cleanup

# Upgrading NVM via gir repo. It not necessary since nvm is installed via homebrew
# echo 'Upateing nvm ...'
# curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | zsh

exit 0
