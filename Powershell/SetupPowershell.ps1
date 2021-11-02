$modules = @(
    @{
        Name            = 'Terminal-Icons'
        RequiredVersion = '0.5.2'
    },
    @{
        Name            = 'PSKubectlCompletion'
        RequiredVersion = '1.0.4'
    },
    @{
        Name            = 'PSReadLine'
        RequiredVersion = '2.2.0-beta4'
        AllowPrerelease = $true
    },
    @{
        Name            = 'PowerShellForGitHub'
        RequiredVersion = '0.16.0'
    },
    @{
        Name            = 'PSFramework'
        RequiredVersion = '1.6.205'
    }
)

$fonts = @(
    [PSCustomObject]@{
        OwnerName      = "ryanoasis"
        RepositoryName = "nerd-fonts"
        AssetName      = "CascadiaCode.zip"
    }
)

$configGitRepoPath = if (Test-Path "$HOME/github/my-setup") { "$HOME/github/my-setup" } elseif (Test-Path "$PSScriptRoot/../../my-setup") { "$PSScriptRoot/../../my-setup" } else { $null }

# Setp terminal icons
Write-Host 'Installing modules ...'
Install-PackageProvider -Name NuGet -MinimumVersion "2.8.5.201" -Force
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
foreach ($module in $modules) {
    Install-Module @module 
}

if (-Not (Test-Path $configGitRepoPath)) {
    Write-Host 'Cloneing config repository ...'
    if (Get-Command git -ErrorAction SilentlyContinue) {
        git clone https://github.com/clowa/my-setup.git $HOME/github/my-setup
    } else {
        Write-Warning 'git cli is not installed. Skipping.'
    }
}

Write-Host 'Copying powershell profile ...'
if (Test-Path $configGitRepoPath) {
    Move-Item -Path $PROFILE -Destination "$PROFILE.backup" -Force
    Copy-Item $configGitRepoPath/Powershell/Microsoft.PowerShell_profile.ps1 $PROFILE -Force
} else {
    Write-Warning "Git repository is not present at $configGitRepoPath. Skipping."
}

###
# Install Fonts
###
Write-Host 'Installing fonts ...'
Import-Module ../modules/FontHelper/FontHelper.psm1
if ($IsWindows -Or $PSVersionTable.PSEdition -eq "Desktop") {
    $tmpDir = New-Item -Path (Join-Path $env:TEMP (New-Guid)) -ItemType Directory
} elseif ($IsMacOs) {
    $tmpDir = New-Item -Path (Join-Path $env:TMPDIR (New-Guid)) -ItemType Directory
}

$tmpLocalFonts = "$tmpDir\fonts"
foreach ($fontRepo in $fonts) {
    $assetZip = Get-GitHubRelease -OwnerName $fontRepo.OwnerName -RepositoryName $fontRepo.RepositoryName -Latest | Get-GitHubReleaseAsset | Where-Object { $_.name -like $fontRepo.AssetName } | Get-GitHubReleaseAsset -Path (Join-Path $tmpDir "asset-$(New-Guid).zip")
    $assetZip | Expand-Archive -DestinationPath $tmpLocalFonts -Force

    Install-Font -Path $tmpLocalFonts
}