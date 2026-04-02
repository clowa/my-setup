Import-Module (Join-Path $PSScriptRoot '../../modules/ConfigurationHelper/ConfigurationHelper.psm1') -Force

$configGitRepoPath = Get-MySetupPath

if (-not $configGitRepoPath) {
    throw 'Could not determine the my-setup repository root.'
}

$claudeConfigPath = Join-Path $HOME '.claude'

if (-not (Test-Path $claudeConfigPath)) {
    New-Item -ItemType Directory -Path $claudeConfigPath -Force | Out-Null
}

# Link directories and files from claude/
$claudeDirectories = Get-ChildItem -Path $PSScriptRoot -Directory | Select-Object -ExpandProperty Name
$claudeFiles = Get-ChildItem -Path $PSScriptRoot -File -Filter '*.json' | Select-Object -ExpandProperty Name

$claudeLinkTargets = $claudeDirectories + $claudeFiles

foreach ($item in $claudeLinkTargets) {
    $targetPath = Join-Path $configGitRepoPath "ai/claude/$item"
    $linkPath = Join-Path $claudeConfigPath $item

    if (Get-ShouldOverwrite -Prompt "~/.claude/$item is present. Do you want to overwrite? (y/n)" -Path $linkPath) {
        New-Item -ItemType SymbolicLink -Path $linkPath -Target $targetPath -Force
    }
}

# Skills live in ai/skills/ (shared with OpenCode) — link explicitly
$skillsTarget = Join-Path $configGitRepoPath 'ai/skills'
$skillsLink = Join-Path $claudeConfigPath 'skills'

if (Get-ShouldOverwrite -Prompt "~/.claude/skills is present. Do you want to overwrite? (y/n)" -Path $skillsLink) {
    New-Item -ItemType SymbolicLink -Path $skillsLink -Target $skillsTarget -Force
}