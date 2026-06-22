# 03. Warnings & TODOs

Some comments earn their place by flagging risk and unfinished work. Warn the reader about non-obvious consequences, mark legitimately deferred work, and amplify what looks trivial but is not.

## Contents

- [03. Warnings \& TODOs](#03-warnings--todos)
  - [Contents](#contents)
  - [Warning of consequences](#warning-of-consequences)
  - [TODO comments](#todo-comments)
  - [Amplification](#amplification)
  - [Rules of thumb](#rules-of-thumb)

## Warning of consequences

Alert the next reader to danger or cost that the code does not reveal on its own: destructive operations, required elevation, slow calls, billing impact, or thread-unsafety. State the consequence and the condition, not just that "care is needed".

**Bad:**

```powershell
function Remove-StaleBackups {
    param([string]$VaultId)

    # cleanup
    Get-AzRecoveryServicesBackupItem -VaultId $VaultId |
        Remove-AzRecoveryServicesBackupItem -Force
}
```

**Good:**

```powershell
function Remove-StaleBackups {
    param([string]$VaultId)

    # WARNING: Destructive and irreversible. Permanently deletes every backup
    # item in the vault, including recovery points. Requires the
    # 'Backup Contributor' role; otherwise each delete throws an
    # authorization error.
    Get-AzRecoveryServicesBackupItem -VaultId $VaultId |
        Remove-AzRecoveryServicesBackupItem -Force
}
```

In Terraform, warn where a seemingly cosmetic field change triggers replacement and data loss. The reader sees an attribute, not the recreation it forces.

**Bad:**

```hcl
resource "azurerm_postgresql_flexible_server" "main" {
  name     = "app-db"
  location = "germanywestcentral" # region
}
```

**Good:**

```hcl
resource "azurerm_postgresql_flexible_server" "main" {
  name = "app-db"

  # WARNING: `location` is immutable. Changing it forces Terraform to DESTROY
  # this server (all data lost) and recreate it. Migrate data first; the
  # prevent_destroy guard below makes such a plan fail rather than apply.
  location = "germanywestcentral"

  lifecycle {
    prevent_destroy = true
  }
}
```

## TODO comments

A `TODO` is a promise, not a wish. Make each one actionable: a consistent tag, the reason it cannot be done now, an owner, and a ticket reference so it can be tracked and closed. A `TODO` with no owner or context is litter that nobody can act on; scan and clear them regularly.

**Bad:**

```powershell
# TODO fix this
$token = Get-CachedToken
```

**Good:**

```powershell
# TODO(OPS-482, cedric): Cached token has no expiry check; refresh once the
# auth service exposes an /introspect endpoint (blocked on PLAT-77).
$token = Get-CachedToken
```

Tag choice signals intent: `TODO` for deferred work, `FIXME` for a known defect, `HACK` for a deliberate workaround. Keep the convention uniform across the codebase so they stay greppable.

## Amplification

Use a comment to amplify the importance of something that looks inconsequential. When a reader would reasonably "tidy up" a line and break behavior, say why it matters.

**Bad:**

```hcl
locals {
  # trim the prefix
  account_name = trimspace(var.storage_prefix)
}
```

**Good:**

```hcl
locals {
  # Trim is significant: a leading space in storage_prefix passes variable
  # validation but yields an invalid storage account name, and the failure
  # only surfaces at apply time with a cryptic Azure error.
  account_name = trimspace(var.storage_prefix)
}
```

## Rules of thumb

- Warn about consequences the code does not show: destruction, cost, elevation, slowness, thread-unsafety.
- Every `TODO` needs an owner and a ticket; otherwise delete it or do it now.
- Use one tag convention (`TODO`/`FIXME`/`HACK`) so comments stay greppable.
- Amplify only what is genuinely non-obvious; routine explanation is noise (see [05-redundancy-and-noise.md](05-redundancy-and-noise.md)).
- Scan and prune warnings and TODOs regularly so they do not rot into lies (see [06-misleading-and-confusing.md](06-misleading-and-confusing.md)).
