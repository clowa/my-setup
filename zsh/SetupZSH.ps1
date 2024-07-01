Import-Module ../modules/ConfigurationHelper/ConfigurationHelper.psm1

$configGitRepoPath = if (Test-Path "$HOME/github/my-setup") { "$HOME/github/my-setup" } elseif (Test-Path "$PSScriptRoot/../../my-setup") { Resolve-Path -Path "$PSScriptRoot/../../my-setup" } else { $null }


if (Get-ShouldOverwrite -Prompt "File ~/.zshrc is present. Do you want to overwrite? (y/n)" -Path $HOME/.zshrc) {
    New-Item -ItemType SymbolicLink -Path $HOME/.zshrc -Target $configGitRepoPath/zsh/.zshrc -Force
}

Write-Host "Setup ZSG Plugins"
New-Item -ItemType SymbolicLink -Path $HOME/.zsh -Target $configGitRepoPath/zsh/.zsh/

$venv = Read-Host "Do you want to run zsh plugins in an virtual python environment? (y/n)"
if ($venv -eq "y") {
    python3 -m venv $configGitRepoPath/zsh/.zsh/venv
    Invoke-Expression "$configGitRepoPath/zsh/.zsh/venv/bin/Activate.ps1"
    pip install -r "$configGitRepoPath/zsh/.zsh/requirements.txt"
}