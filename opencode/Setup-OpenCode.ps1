Import-Module ../modules/ConfigurationHelper/ConfigurationHelper.psm1

$configGitRepoPath = Get-MySetupPath

$openCodeDirectories = @(
    "opencode/agents",
    "opencode/tools",
    "opencode/skills"
)


foreach ($dir in $openCodeDirectories) {
    if (Get-ShouldOverwrite -Prompt "Folder ~/.config/$dir is present. Do you want to overwrite? (y/n)" -Path "$HOME/.config/$dir") {
        New-Item -ItemType SymbolicLink -Path "$HOME/.config/$dir" -Target "$configGitRepoPath/$dir" -Force
    }
}
