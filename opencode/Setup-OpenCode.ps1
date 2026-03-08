Import-Module (Join-Path $PSScriptRoot '../modules/ConfigurationHelper/ConfigurationHelper.psm1') -Force

$configGitRepoPath = Get-MySetupPath

if (-not $configGitRepoPath) {
    throw 'Could not determine the my-setup repository root.'
}

$openCodeConfigPath = Join-Path $HOME '.config/opencode'

if (-not (Test-Path $openCodeConfigPath)) {
    New-Item -ItemType Directory -Path $openCodeConfigPath -Force | Out-Null
}

$openCodeDirectories = Get-ChildItem -Path $PSScriptRoot -Directory | Select-Object -ExpandProperty Name
$openCodeFiles = Get-ChildItem -Path $PSScriptRoot -File -Filter '*.jsonc' | Select-Object -ExpandProperty Name

$openCodeLinkTargets = $openCodeDirectories + $openCodeFiles

foreach ($item in $openCodeLinkTargets) {
    $targetPath = Join-Path $configGitRepoPath "opencode/$item"
    $linkPath = Join-Path $openCodeConfigPath $item

    if (Get-ShouldOverwrite -Prompt "Folder ~/.config/opencode/$item is present. Do you want to overwrite? (y/n)" -Path $linkPath) {
        New-Item -ItemType SymbolicLink -Path $linkPath -Target $targetPath -Force
    }
}
