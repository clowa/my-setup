# 06. Misleading & Confusing

A comment that is subtly wrong is worse than no comment at all: it sends the reader down the wrong path with false confidence. The code is the source of truth; any comment that contradicts it is a defect.

## Contents

- [06. Misleading \& Confusing](#06-misleading--confusing)
  - [Contents](#contents)
  - [Misleading comments](#misleading-comments)
  - [Outdated / stale comments](#outdated--stale-comments)
  - [Mandated comments](#mandated-comments)
  - [Rules of thumb](#rules-of-thumb)

## Misleading comments

An imprecise comment lies even when the author meant well. If it claims a unit, default, or behavior the code does not deliver, the reader trusts the comment and gets burned. Correct the claim, or delete it and let the code speak.

**Bad:**

```powershell
function Get-SessionAge {
    # Returns the session age in minutes.
    param([datetime]$StartTime)
    return [int]((Get-Date) - $StartTime).TotalSeconds
}
```

**Good:**

```powershell
function Get-SessionAgeSeconds {
    param([datetime]$StartTime)
    return [int]((Get-Date) - $StartTime).TotalSeconds
}
```

The fix moves the truth into the name. When a precise name makes the unit obvious, the comment is redundant (see [05-redundancy-and-noise.md](05-redundancy-and-noise.md)).

## Outdated / stale comments

Code changes far more often than the comments around it. A comment that once matched a value rots silently until it contradicts the code. The reader cannot tell which is right, so trust in every nearby comment erodes (see [01-introducing-comments.md](01-introducing-comments.md) on comment rot). When you touch the code, fix or remove the comment in the same change.

**Bad:**

```hcl
# Default region is West Europe; create timeout is 30s.
resource "azurerm_storage_account" "logs" {
  name                     = "stlogsprod"
  resource_group_name      = azurerm_resource_group.core.name
  location                 = "northeurope"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  timeouts {
    create = "60m"
  }
}
```

The comment claims West Europe and 30s while the code uses `northeurope` and a 60m create timeout. Both claims are false. Delete the comment and let the attributes speak; they already state the region and timeout unambiguously.

**Good:**

```hcl
resource "azurerm_storage_account" "logs" {
  name                     = "stlogsprod"
  resource_group_name      = azurerm_resource_group.core.name
  location                 = "northeurope"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  timeouts {
    create = "60m"
  }
}
```

If a non-obvious *reason* for `northeurope` exists (for example, a data-residency requirement), state that intent instead of restating the value (see [02-context-and-intent.md](02-context-and-intent.md)).

## Mandated comments

A policy that every function, parameter, and variable must carry a comment does not produce understanding. It produces filler that paraphrases the signature, and that filler drifts out of date the moment the signature changes. Worse, it trains the reader to skim past comments, so the rare valuable one is ignored too.

**Bad:**

```powershell
function Set-RetryPolicy {
    # Configures the retry policy.
    param(
        # The retry count.
        [int]$RetryCount,
        # The delay in seconds.
        [int]$DelaySeconds
    )
    # ...
}
```

**Good:**

```powershell
function Set-RetryPolicy {
    param(
        [int]$RetryCount,
        # Capped at 30s by the upstream gateway; higher values are silently ignored.
        [int]$DelaySeconds
    )
    # ...
}
```

Drop the comments that merely echo the names. Keep only the one that tells the reader something the signature cannot: a real constraint they would otherwise get wrong.

## Rules of thumb

- A comment that contradicts the code is a bug; fix it in the same change that touched the code.
- If a comment only restates the code, delete it and let a precise name carry the meaning.
- Encode units, defaults, and limits in names and values, not in prose that can drift.
- Never adopt a "comment everything" policy; mandated comments breed lies and train readers to ignore comments.
- When in doubt about a stale claim, trust the code and remove the comment rather than guess.
