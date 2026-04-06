Import-Module (Join-Path $PSScriptRoot '../../modules/ConfigurationHelper/ConfigurationHelper.psm1') -Force

$configGitRepoPath = Get-MySetupPath

if (-not $configGitRepoPath) {
    throw 'Could not determine the my-setup repository root.'
}

$claudeConfigPath = Join-Path $HOME '.claude'

if (-not (Test-Path $claudeConfigPath)) {
    New-Item -ItemType Directory -Path $claudeConfigPath -Force | Out-Null
}

# Link directories and files from claude/
$claudeDirectories = Get-ChildItem -Path $PSScriptRoot -Directory | Select-Object -ExpandProperty Name
$claudeFiles = Get-ChildItem -Path $PSScriptRoot -File -Filter '*.json' | Select-Object -ExpandProperty Name

$claudeLinkTargets = @($claudeDirectories) + @($claudeFiles)

foreach ($item in $claudeLinkTargets) {
    $targetPath = Join-Path $configGitRepoPath "ai/claude/$item"
    $linkPath = Join-Path $claudeConfigPath $item

    if (-not (Test-Path $targetPath)) {
        Write-Warning "Skipping '$item': target not found at '$targetPath'"
        continue
    }

    $kind = if (Test-Path $targetPath -PathType Container) { 'Directory' } else { 'File' }

    if (Get-ShouldOverwrite -Prompt "$kind ~/.claude/$item is present. Do you want to overwrite? (y/n)" -Path $linkPath) {
        New-Item -ItemType SymbolicLink -Path $linkPath -Target $targetPath -Force
    }
}

# Register MCP servers at user scope (settings.json does not support mcpServers)
$mcpServers = @(
    @{ Name = 'terraform_registry'; Transport = 'stdio'; Command = 'docker'; Args = @('run', '-i', '--rm', 'hashicorp/terraform-mcp-server:0.4.0') },
    @{ Name = 'microsoft_azure';    Transport = 'stdio'; Command = 'docker'; Args = @('run', '-i', '--rm', 'mcr.microsoft.com/azure-sdk/azure-mcp:latest') },
    @{ Name = 'microsoft_docs';     Transport = 'http';  Url = 'https://learn.microsoft.com/api/mcp' },
    @{ Name = 'datadog';            Transport = 'http';  Url = 'https://mcp.us3.datadoghq.com/api/unstable/mcp-server/mcp?toolsets=all' }
)

foreach ($server in $mcpServers) {
    Write-Host "Registering MCP server '$($server.Name)'..."
    if ($server.Transport -eq 'http') {
        claude mcp add --scope user --transport http $server.Name $server.Url
    } else {
        claude mcp add --scope user --transport stdio $server.Name $server.Command -- @($server.Args)
    }
}

# Skills live in ai/skills/ (shared with OpenCode) — link explicitly
$skillsTarget = Join-Path $configGitRepoPath 'ai/skills'
$skillsLink = Join-Path $claudeConfigPath 'skills'

if (-not (Test-Path $skillsTarget)) {
    Write-Warning "Skipping 'skills': target not found at '$skillsTarget'"
} elseif (Get-ShouldOverwrite -Prompt "Directory ~/.claude/skills is present. Do you want to overwrite? (y/n)" -Path $skillsLink) {
    New-Item -ItemType SymbolicLink -Path $skillsLink -Target $skillsTarget -Force
}