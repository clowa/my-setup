function Install-Font {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # Specifies the font name to install.  Default value will install all fonts.
        [Parameter(Position = 0)]
        [string[]]
        $FontName = '*',

        # Specifies the path of the font files to install.  Default value is the current working directory.
        [Parameter(Position = 1)]
        [string]
        $Path = $PWD
    )

    if ($IsWindows -Or $PSVersionTable.PSEdition -eq "Desktop") {
        # Set font directorys for windows systmes.
        $systemFontsDir = "C:\Windows\Fonts"
        $userFontsDir = "$($env:LOCALAPPDATA)\Microsoft\Windows\Fonts"
    } elseif ($IsMacOs) {
        # Set font directorys for macOS systmes.
        $systemFontsDir = "/Library/Fonts/"
        $userFontsDir = "$HOME/Library/Fonts"
    }

    $fontFiles = New-Object 'System.Collections.Generic.List[System.IO.FileInfo]'
    foreach ($aFontName in $FontName) {
        Get-ChildItem $Path -Filter "${aFontName}.ttf" -Recurse | ForEach-Object { $fontFiles.Add($_) }
        # Get-ChildItem $Path -Filter "${aFontName}.otf" -Recurse | ForEach-Object { $fontFiles.Add($_) }
    }

    $fonts = $null
    foreach ($fontFile in $fontFiles) {
        if ($PSCmdlet.ShouldProcess($fontFile.Name, "Install Font")) {
            
            $alreadyInstalled = (
                (Get-ChildItem -Path (Join-Path $userFontsDir $fontFile.Name) -ErrorAction SilentlyContinue).Length -gt 0 -or
                (Get-ChildItem -Path (Join-Path $systemFontsDir $fontFile.Name) -ErrorAction SilentlyContinue).Length -gt 0
            )
            
            if (-Not $alreadyInstalled) {
                if ($IsWindows -Or $PSVersionTable.PSEdition -eq "Desktop") {
                    if (!$fonts) {
                        $shellApp = New-Object -ComObject shell.application
                        $fonts = $shellApp.NameSpace(0x14)
                    }
                    $fonts.CopyHere($fontFile.FullName)
                } elseif ($IsMacOs) {
                    Copy-Item $fontFile.FullName $userFontsDir
                }
            }
        }
    }
}

function Install-FontFromGitHub {
    #Requires -Modules PowerShellForGitHub
    param (
        # Owner of the repository.
        [Parameter(Mandatory)]
        [String]
        $OwnerName,

        # Name of the repository.
        [Parameter(Mandatory)]
        [String]
        $RepositoryName,

        # Display name of the asset with the latest release.
        [Parameter(Mandatory)]
        [String]
        $AssetName
    )

    if ($IsWindows -Or $PSVersionTable.PSEdition -eq "Desktop") {
        $tmp = $env:TEMP
    } elseif ($IsMacOs) {
        $tmp = $env:TMPDIR
    } else {
        Write-Warning "OS is not supported."
        return $false
    }
    $tmpDir = New-Item -Path (Join-Path $tmp (New-Guid)) -ItemType Directory
    $tmpLocalFonts = "$tmpDir\fonts"
    Write-Verbose "Temporary directory is: $tmpDir"

    try {
        Write-Verbose "Get asset $AssetName of $OwnerName/$RepositoryName from the latest GitHub release ..."
        $asset = Get-GitHubRelease -OwnerName $OwnerName -RepositoryName $RepositoryName -Latest |
        Get-GitHubReleaseAsset |
        Where-Object { $_.name -like $AssetName } |
        Select-Object -First 1

        # Exit if query doesn't return any result.
        # Exit if downloaded asset is not of type zip.
        if (-Not $asset) {
            Write-Warning "Asset $AssetName not found."
            return $false
        } elseif (-Not ([IO.Path]::GetExtension($asset.Name) -eq ".zip")) {
            Write-Warning "Asset is not of type zip. It's of type $([IO.Path]::GetExtension($asset.Name))."
            return $false
        }

        Write-Verbose "Downloading asset ..."
        $assetZip = $asset | Get-GitHubReleaseAsset -Path (Join-Path $tmpDir "$OwnerName_$RepositoryName_asset-$($asset.id).zip")

        Write-Verbose "Extracting zip asset ..."
        $assetZip | Expand-Archive -DestinationPath $tmpLocalFonts -Force
        
        Install-Font -Path $tmpLocalFonts
    } catch {
        Write-Warning $_
    } finally {
        Write-Verbose "Removing temporary directory ..."
        Remove-Item -Path $tmpDir -Recurse
    }   
}