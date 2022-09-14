Import-Module ../modules/ConfigurationHelper/ConfigurationHelper.psm1

$configGitRepoPath = if (Test-Path "$HOME/github/my-setup") { "$HOME/github/my-setup" } elseif (Test-Path "$PSScriptRoot/../../my-setup") { Resolve-Path -Path "$PSScriptRoot/../../my-setup" } else { $null }


if (Get-ShouldOverwrite -Prompt "File ~/.zshrc is present. Do you want to overwrite? (y/n)" -Path $HOME/.zshrc) {
    New-Item -ItemType SymbolicLink -Path $HOME/.zshrc -Target $configGitRepoPath/zsh/.zshrc -Force
}

New-Item -ItemType SymbolicLink -Path $HOME/.zsh -Target $configGitRepoPath/zsh/.zsh/