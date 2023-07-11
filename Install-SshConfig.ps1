## SSH config

Get-ChildItem "$PSScriptRoot/.ssh" | ForEach-Object {
    New-Item -ItemType SymbolicLink -Path "$HOME/.ssh/$($_.Name)" -Target $_.FullName -Force
}
