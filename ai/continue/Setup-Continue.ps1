Import-Module (Join-Path $PSScriptRoot '../../modules/ConfigurationHelper/ConfigurationHelper.psm1') -Force

$configGitRepoPath = Get-MySetupPath

if (-not $configGitRepoPath) {
    throw 'Could not determine the my-setup repository root.'
}

$continueConfigPath = Join-Path $HOME '.continue'

if (-not (Test-Path $continueConfigPath)) {
    New-Item -ItemType Directory -Path $continueConfigPath -Force | Out-Null
}

# Link individual tracked files from ai/continue/
$trackedFiles = @('config.yaml', '.env.tpl', 'README.md', '.continueignore', '.continuerc.json')

foreach ($file in $trackedFiles) {
    $targetPath = Join-Path $configGitRepoPath "ai/continue/$file"
    $linkPath = Join-Path $continueConfigPath $file

    if (-not (Test-Path $targetPath)) {
        Write-Warning "Skipping '$file': target not found at '$targetPath'"
        continue
    }

    if (Get-ShouldOverwrite -Prompt "File ~/.continue/$file is present. Do you want to overwrite? (y/n)" -Path $linkPath) {
        New-Item -ItemType SymbolicLink -Path $linkPath -Target $targetPath -Force
    }
}

# Inject API keys from 1Password into .env
$envFile = Join-Path $continueConfigPath '.env'
$envTpl = Join-Path $continueConfigPath '.env.tpl'

if (Get-ShouldOverwrite -Prompt "File ~/.continue/.env is present. Do you want to regenerate from 1Password? (y/n)" -Path $envFile) {
    Write-Host "Injecting secrets from 1Password..."
    op inject -i $envTpl -o $envFile
}
