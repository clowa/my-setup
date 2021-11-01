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

$configGitRepoPath = '~/github/my-setup'

# Setp terminal icons
Write-Host 'Installing modules ...'
foreach ($module in $modules) {
    Install-Module $module 
}

Write-Host 'Cloneing config repository ...'
if (Get-Command git) {
    git clone https://github.com/clowa/my-setup.git
} else {
    Write-Warning 'git cli is not installed. Skipping.'
}

Write-Host 'Copying powershell profile ...'
if (Test-Path $configGitRepoPath) {
    Copy-Item $configGitRepoPath/Powershell/Microsoft.PowerShell_profile.ps1 -Force
} else {
    Write-Warning "Git repository is not present at $configGitRepoPath. Skipping."
}