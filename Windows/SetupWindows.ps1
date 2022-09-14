#Requires -Modules PowerShellForGitHub

# Disable telemetry for GitHub module
Set-GitHubConfiguration -DisableTelemetry

$apps = @(
    # CLI
    "powershell-core"
    "oh-my-posh"

    "awscli"
    "azure-cli"    
    "kubernetes-cli"
    "kubernetes-helm"
    "aws-iam-authenticator"

    "packer"
    "terraform"
    "terraform-docs"
    "tfsec"
    "tflint"

    "docker-compose"
    "git"
    "gh"
    "grep"
    "gzip"
    "jq"
    "pandoc"
    
    # GUI
    "docker-desktop"
    "vscode"
    "powertoys"
)

# $vsCodeExtensions = @(
#     "vscode-prettier"
# )

$fonts = @(
    [PSCustomObject]@{
        OwnerName      = "ryanoasis"
        RepositoryName = "nerd-fonts"
        AssetName      = "CascadiaCode.zip"
    }
)

# Global script variables
$Config = [PSCustomObject]@{
    tmpDir         = New-Item -Path "$env:TEMP\$(New-Guid)" -ItemType Directory
    rebootRequired = $false
}

###
# Install Chocolatey
###
Write-Host "Installing chocolatey ... "
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

###
# Install apps
###
Write-Host "Installing apps ... "
choco install --yes --no-progress --requirechecksum $apps -join ", "
# Check if reboot is required.
if ($LASTEXITCODE -eq 1641 -or $LASTEXITCODE -eq 3010) {
    $Config.rebootRequired = $true
}

###
# Install WSL Ubuntu
###
Write-Host "Installing ubuntu ... "
wsl --install -d Ubuntu

###
# Install Fonts
###
Write-Host 'Installing fonts ...'
Import-Module ../modules/FontHelper/FontHelper.psm1

$tmpDir = New-Item -Path (Join-Path $env:TEMP (New-Guid)) -ItemType Directory
$tmpLocalFonts = "$tmpDir\fonts"

foreach ($fontRepo in $fonts) {
    $assetZip = Get-GitHubRelease -OwnerName $fontRepo.OwnerName -RepositoryName $fontRepo.RepositoryName -Latest | Get-GitHubReleaseAsset | Where-Object { $_.name -like $fontRepo.AssetName } | Get-GitHubReleaseAsset -Path (Join-Path $tmpDir "asset-$(New-Guid).zip")
    $assetZip | Expand-Archive -DestinationPath $tmpLocalFonts -Force

    Install-Font -Path $tmpLocalFonts
}
