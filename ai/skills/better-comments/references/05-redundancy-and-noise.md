# 05. Redundancy & Noise

A comment that restates the code adds nothing: it costs reading time and earns no information. Delete it, or move the meaning into a better name. See [01-introducing-comments.md](01-introducing-comments.md) for why code that explains itself beats a comment.

## Contents
- [Redundant comments](#redundant-comments)
- [Noise comments](#noise-comments)
- [Prefer a name over a comment](#prefer-a-name-over-a-comment)
- [Rules of thumb](#rules-of-thumb)

## Redundant comments

A redundant comment paraphrases the line below it. It takes longer to read than the code and conveys nothing the reader cannot already see.

**Bad:**
```powershell
function Get-RetryCount {
    # set the count to zero
    $count = 0
    # loop while count is less than max
    while ($count -lt $MaxRetries) {
        # increment the counter
        $count++
    }
    # return the count
    return $count
}
```

**Good:**
```powershell
function Get-RetryCount {
    $count = 0
    while ($count -lt $MaxRetries) {
        $count++
    }
    return $count
}
```

## Noise comments

Noise comments state the obvious or repeat ceremony: default banners, type labels, and "what this block is" headers. They survive copy-paste and template scaffolding long after they stopped meaning anything. (For comments that mislead because the code drifted, see [06-misleading-and-confusing.md](06-misleading-and-confusing.md); for banner and divider formatting, see [08-visual-clutter-and-formatting.md](08-visual-clutter-and-formatting.md).)

**Bad:**
```hcl
# resource group
resource "azurerm_resource_group" "main" {
  # the name
  name     = "rg-payments-prod"
  # the location
  location = "westeurope"
}
```

**Good:**
```hcl
resource "azurerm_resource_group" "main" {
  name     = "rg-payments-prod"
  location = "westeurope"
}
```

## Prefer a name over a comment

When a comment explains *what* an expression or value means, that meaning belongs in the code. Extract a well-named variable, function, or local instead of annotating an opaque expression or a magic number.

**Bad:**
```powershell
# user is active, was seen within the last 30 days, and is not a service account
if ($u.Enabled -and $u.LastLogon -gt (Get-Date).AddDays(-30) -and -not $u.IsService) {
    Send-RenewalNotice -User $u
}
```

**Good:**
```powershell
$isEligibleForRenewal = $u.Enabled `
    -and $u.LastLogon -gt (Get-Date).AddDays(-30) `
    -and -not $u.IsService

if ($isEligibleForRenewal) {
    Send-RenewalNotice -User $u
}
```

The same applies to magic numbers: name the value so the comment becomes unnecessary.

**Bad:**
```hcl
resource "azurerm_storage_management_policy" "logs" {
  storage_account_id = azurerm_storage_account.logs.id

  rule {
    name    = "expire-logs"
    enabled = true
    actions {
      base_blob {
        # delete after 90 days for compliance retention
        delete_after_days_since_modification_greater_than = 90
      }
    }
  }
}
```

**Good:**
```hcl
locals {
  log_compliance_retention_days = 90
}

resource "azurerm_storage_management_policy" "logs" {
  storage_account_id = azurerm_storage_account.logs.id

  rule {
    name    = "expire-logs"
    enabled = true
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = local.log_compliance_retention_days
      }
    }
  }
}
```

## Rules of thumb

- If a comment only restates the code on the next line, delete it.
- Strip ceremonial banners and type labels left over from templates; they are noise.
- Before writing an explanatory comment, try a better variable or function name first.
- Promote magic numbers to named locals or constants so the name carries the meaning.
- Ask: does this comment tell the reader something the code cannot? If not, remove it.
