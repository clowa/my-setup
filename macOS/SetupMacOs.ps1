# Install ob my posh as promt engine
if (!(Get-Command -Name brew -ErrorAction SilentlyContinue)) {
    Write-Warning "Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

Write-Host "Installing Homebrew packages..."
brew bundle install --file=$PSScriptRoot/Brewfile
