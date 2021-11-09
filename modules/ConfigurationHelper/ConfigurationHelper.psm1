function Get-ShouldOverwrite {
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $Path,

        [Parameter()]
        [String]
        $Prompt
    )

    if (Test-Path $Path) {
        $answer = Read-Host -Prompt $Prompt 
        if ($answer -eq "y" -or $answer -eq "yes") {
            return $true
        }
    }

    return $false
}
