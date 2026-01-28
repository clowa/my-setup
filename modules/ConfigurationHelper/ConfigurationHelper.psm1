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

    if (-not (Test-Path $Path)) {
        Write-Verbose "Path is not present."
        return $true
    }

    $answer = Read-Host -Prompt $Prompt 
    if ($answer -eq "y" -or $answer -eq "yes") {
        return $true
    }
    
    return $false
}

function Get-MySetupPath {
    $mySetupPath = $null


    if (Test-Path "$HOME/github/my-setup") { 
        $mySetupPath = "$HOME/github/my-setup" 

    } elseif (Test-Path "$PSScriptRoot/../../my-setup") {
        $mySetupPath = Resolve-Path -Path "$PSScriptRoot/../../my-setup" 
    } 

    return $mySetupPath
}
