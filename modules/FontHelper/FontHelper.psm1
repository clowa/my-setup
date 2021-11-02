function Install-Font {
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
            
            $alreadyInstalled = (Get-ChildItem -Path (Join-Path $userFontsDir $fontFile.Name) -ErrorAction SilentlyContinue).Length -gt 0 -or (Get-ChildItem -Path (Join-Path $systemFontsDir $fontFile.Name) -ErrorAction SilentlyContinue).Length -gt 0
            
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