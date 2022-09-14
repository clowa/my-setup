Import-Module ./modules/FontHelper/FontHelper.psm1

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