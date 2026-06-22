# 07. Version Control vs Code

Git already records history, authorship, and every past version of a line. A comment that duplicates what version control tracks is dead weight: it rots, clutters the file, and tells the reader nothing `git log` or `git blame` would not. Rule of thumb: if Git can remember it, do not comment it.

## Contents

- [07. Version Control vs Code](#07-version-control-vs-code)
  - [Contents](#contents)
  - [Commented-out code](#commented-out-code)
  - [Journal / changelog comments](#journal--changelog-comments)
  - [Attributions \& bylines](#attributions--bylines)
  - [Rules of thumb](#rules-of-thumb)

## Commented-out code

Code left commented "just in case" is the worst of both worlds: not run, not tested, not deleted. The next reader dares not remove it because they assume it still matters, so it lingers for years and rots. Delete it — Git has it if you ever need it back (`git log -p`, `git show`).

**Bad:**

```powershell
function Get-ActiveUsers {
    # Old AD query - keep in case we roll back
    # $users = Get-ADUser -Filter * -Properties LastLogonDate |
    #     Where-Object { $_.Enabled -and $_.LastLogonDate -gt (Get-Date).AddDays(-30) }
    return Get-MgUser -Filter "accountEnabled eq true" -All
}
```

**Good:**

```powershell
function Get-ActiveUsers {
    return Get-MgUser -Filter "accountEnabled eq true" -All
}
```

The same applies to infrastructure. A commented-out resource is invisible to `terraform plan` and only makes the next reader wonder whether it should come back.

**Bad:**

```hcl
resource "azurerm_storage_account" "logs" {
  name                     = "stlogsprod"
  resource_group_name      = azurerm_resource_group.core.name
  location                 = "westeurope"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# resource "azurerm_storage_account" "logs_old" {
#   name                     = "stlogsprodold"
#   account_tier             = "Standard"
#   account_replication_type = "GRS"
# }
```

**Good:**

```hcl
resource "azurerm_storage_account" "logs" {
  name                     = "stlogsprod"
  resource_group_name      = azurerm_resource_group.core.name
  location                 = "westeurope"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

## Journal / changelog comments

A running edit log at the top of a file recreates, badly, what Git already stores. It drifts, never gets pruned, and conflicts on every merge. Let commit messages carry the history.

**Bad:**

```powershell
# Changelog:
# 2024-01-12  jdoe    Initial version
# 2024-03-04  asmith  Added retry logic
# 2024-06-21  jdoe    Switched to Graph API, dropped the AzureAD module
# 2024-09-02  bptel   Fixed paging bug
function Sync-Users {
    # ...
}
```

**Good:**

```powershell
function Sync-Users {
    # ...
}
```

`git log` reconstructs the journal on demand, accurately. Capture the *why* of each change in a good commit message, where it belongs (see the `git-commit-message` skill).

## Attributions & bylines

`# Added by Bob`, `# Author: A. Smith`, `# Modified by the platform team` — Git attributes every line already. Bylines go stale (Bob left two years ago), and the implied ownership discourages others from improving the code.

**Bad:**

```hcl
# Added by Bob T. (2023-04-01) - do not edit without asking me
resource "azurerm_key_vault" "main" {
  name                = "kv-payments-prod"
  sku_name            = "standard"
  tenant_id           = var.tenant_id
  resource_group_name = azurerm_resource_group.core.name
  location            = azurerm_resource_group.core.location
}
```

**Good:**

```hcl
resource "azurerm_key_vault" "main" {
  name                = "kv-payments-prod"
  sku_name            = "standard"
  tenant_id           = var.tenant_id
  resource_group_name = azurerm_resource_group.core.name
  location            = azurerm_resource_group.core.location
}
```

Run `git blame` to see who last touched a line and `git log` for why. If a comment about a value's *intent* is genuinely useful, write that intent (see [02-context-and-intent.md](02-context-and-intent.md)) rather than a byline.

## Rules of thumb

- Delete commented-out code; `git log -p` and `git show` recover any past version.
- Don't keep a changelog in the source file; let commit messages and `git log` be the history.
- Remove author bylines and "modified by" tags; `git blame` attributes every line.
- Put the *why* of a change in a good commit message, not a comment (see the `git-commit-message` skill).
- If version control already records it, it does not belong in a comment.
