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

$configGitRepoPath = "$HOME/github/my-setup"

# Setp terminal icons
Write-Host 'Installing modules ...'
foreach ($module in $modules) {
    Install-Module @module 
}

if (Test-Path $configGitRepoPath) {
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