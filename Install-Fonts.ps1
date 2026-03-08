Import-Module (Join-Path $PSScriptRoot 'modules/FontHelper/FontHelper.psm1') -Force

$fonts = @(
    @{
        OwnerName      = "ryanoasis"
        RepositoryName = "nerd-fonts"
        AssetName      = "CascadiaCode.zip"
    }
)

###
# Install Fonts
###
Write-Host 'Installing fonts ...'

foreach ($fontRepo in $fonts) {
    Install-FontFromGitHub @fontRepo
}
