[CmdletBinding()]
param (
    [Parameter(
        Position = 1
    )]
    [String]
    $Profile
)


if (-not (Get-Command databricks -ErrorAction SilentlyContinue)) {
    Write-Error "Databricks CLI is not installed. Please install it from https://docs.databricks.com/dev-tools/cli/index.html"
    exit 1
}

databricks token-management list -o json -p $Profile | ConvertFrom-Json | ForEach-Object {
    [PSCustomObject]@{
        Comment           = $_.comment
        CreatedById       = $_.created_by_id
        CreatedByUsername = $_.created_by_username
        CreationTime      = [System.DateTimeOffset]::FromUnixTimeMilliseconds($_.creation_time).DateTime
        ExpiryTime        = if ($_.expiry_time) { [System.DateTimeOffset]::FromUnixTimeMilliseconds($_.expiry_time).DateTime } else { $null } 
        LastUsedDay       = if ($_.last_used_day) { [System.DateTimeOffset]::FromUnixTimeMilliseconds($_.last_used_day).DateTime } else { $null }
        OwnerId           = $_.owner_id
        TokenId           = $_.token_id
    }
}
