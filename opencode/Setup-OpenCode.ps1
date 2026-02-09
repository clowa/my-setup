Import-Module ../modules/ConfigurationHelper/ConfigurationHelper.psm1

$configGitRepoPath = Get-MySetupPath

$openCodeDirectories = Get-ChildItem -Path $PSScriptRoot -Directory | Select-Object -ExpandProperty Name
$openCodeFiles = Get-ChildItem -Path $PSScriptRoot -File -Filter '*.jsonc' | Select-Object -ExpandProperty Name

$openCodeLinkTargets = $openCodeDirectories + $openCodeFiles

foreach ($item in $openCodeLinkTargets) {
    if (Get-ShouldOverwrite -Prompt "Folder ~/.config/opencode/$item is present. Do you want to overwrite? (y/n)" -Path "$HOME/.config/opencode/$item") {
        New-Item -ItemType SymbolicLink -Path "$HOME/.config/opencode/$item" -Target "$configGitRepoPath/opencode/$item" -Force
    }
}
