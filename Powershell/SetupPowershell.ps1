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

$configGitRepoPath = "$HOME/github/my-setup"

# Setp terminal icons
Write-Host 'Installing modules ...'
foreach ($module in $modules) {
    Install-Module @module 
}

if (-Not (Test-Path $configGitRepoPath)) {
    Write-Host 'Cloneing config repository ...'
    if (Get-Command git) {
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

if ($IsWindows) {
    $systemFontsDir = "C:\Windows\Fonts"
    $userFontsDir = "$($env:LOCALAPPDATA)\Microsoft\Windows\Fonts"
    $tmpDir = New-Item -Path (Join-Path $env:TEMP (New-Guid)) -ItemType Directory
} elseif ($IsMacOs) {
    $systemFontsDir = "/Library/Fonts/"
    $userFontsDir = "$HOME/Library/Fonts"
    $tmpDir = New-Item -Path (Join-Path $env:TMPDIR (New-Guid)) -ItemType Directory
}

$tmpLocalFonts = "$tmpDir\fonts"
foreach ($fontRepo in $fonts) {
    if ($IsWindows) {
        $objShell = New-Object -ComObject Shell.Application
        $objFolder = $objShell.Namespace(0x14)
    }

    $assetZip = Get-GitHubRelease -OwnerName $fontRepo.OwnerName -RepositoryName $fontRepo.RepositoryName -Latest | Get-GitHubReleaseAsset | Where-Object { $_.name -like $fontRepo.AssetName } | Get-GitHubReleaseAsset -Path (Join-Path $tmpDir "asset-$(New-Guid).zip")
    $assetZip | Expand-Archive -DestinationPath $tmpLocalFonts -Force

    foreach ($fileTTF in Get-ChildItem $tmpLocalFonts -Filter *.ttf -Recurse) {
        
        $alreadyInstalled = (Get-ChildItem -Path (Join-Path $userFontsDir $fileTTF.Name) -ErrorAction SilentlyContinue).Length -gt 0 -or (Get-ChildItem -Path (Join-Path $systemFontsDir $fileTTF.Name) -ErrorAction SilentlyContinue).Length -gt 0

        if (-Not $alreadyInstalled) {
            if ($IsWindows) {
                $objFolder.CopyHere($fileTTF.fullname, 0x10)
            } elseif ($IsMacOs) {
                Copy-Item $fileTTF.FullName $userFontsDir
            }
            
        }
        Remove-Item $fileTTF
    }
}