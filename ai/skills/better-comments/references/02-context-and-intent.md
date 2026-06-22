# 02. Explaining Context & Intent

The code already says *what* it does; a good comment says *why*. Comment the intent, constraint, or rationale a reader cannot recover from the code itself.

## Contents

- [02. Explaining Context \& Intent](#02-explaining-context--intent)
  - [Contents](#contents)
  - [Explanation of intent](#explanation-of-intent)
  - [Clarification of the obscure-but-unchangeable](#clarification-of-the-obscure-but-unchangeable)
  - [Informative comments](#informative-comments)
  - [Context the code cannot convey](#context-the-code-cannot-convey)
  - [Rules of thumb](#rules-of-thumb)

## Explanation of intent

When you choose a non-obvious approach over the one a reader would expect, record *why*. Numbers and waits that look arbitrary almost always encode an external constraint.

**Bad:**

```powershell
# Sleep for 2 seconds, then retry the request
Start-Sleep -Seconds 2
$response = Invoke-RestMethod -Uri $url
```

**Good:**

```powershell
# Upstream billing API rate-limits to 30 req/min and returns 429 without a
# Retry-After header; 2s between calls keeps us under the cap. See INFRA-812.
Start-Sleep -Seconds 2
$response = Invoke-RestMethod -Uri $url
```

## Clarification of the obscure-but-unchangeable

When you cannot rename or restructure a thing — a third-party return shape, a regex, a constant mandated by an external system — translate it into readable terms so the reader need not reverse-engineer it.

**Bad:**

```powershell
# Match the value
if ($id -match '^[A-Z]{2}\d{6}[A-Z]$') {
    Submit-Order -CustomerId $id
}
```

**Good:**

```powershell
# Legacy ERP customer number: 2-letter region, 6 digits, 1 check letter (e.g. DE004217X).
# Format is fixed by the vendor and validated again server-side.
if ($id -match '^[A-Z]{2}\d{6}[A-Z]$') {
    Submit-Order -CustomerId $id
}
```

## Informative comments

State the format or unit a value is expected to match when the type alone does not reveal it. This saves the reader a trip to an external spec.

**Good:**

```hcl
variable "retention_window" {
  type        = string
  description = "Backup retention as an ISO-8601 duration, e.g. P30D (30 days)."
  default     = "P30D"
}
```

## Context the code cannot convey

Business rules, external constraints, and links to the spec or ticket explaining a decision live nowhere in the code. A setting that looks like a mistake needs a comment proving it is deliberate.

**Bad:**

```hcl
resource "azurerm_storage_account" "audit" {
  name                          = "stauditprod"
  resource_group_name           = azurerm_resource_group.audit.name
  location                      = azurerm_resource_group.audit.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  public_network_access_enabled = false

  lifecycle {
    # Ignore changes to tags
    ignore_changes = [tags]
  }
}
```

**Good:**

```hcl
resource "azurerm_storage_account" "audit" {
  name                     = "stauditprod"
  resource_group_name      = azurerm_resource_group.audit.name
  location                 = azurerm_resource_group.audit.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Audit data must never traverse the public internet (ISO 27001 control A.13.1).
  # Reach it via the private endpoint in network.tf only.
  public_network_access_enabled = false

  lifecycle {
    # FinOps tags are applied by an Azure Policy after apply; ignoring them here
    # prevents Terraform from reverting policy-managed tags on every plan. See OPS-1453.
    ignore_changes = [tags]
  }
}
```

## Rules of thumb

- Comment the *why*, never the *what* — if the comment restates the code, delete it (see [05-redundancy-and-noise.md](05-redundancy-and-noise.md)).
- Any magic number, wait, or "wrong-looking" setting deserves the constraint that forces it.
- Link the spec, ticket, or vendor doc that justifies a non-obvious decision; future readers cannot infer it.
- Translate the unchangeable (regex, vendor format, external constant) into plain terms instead of leaving the reader to decode it.
- If you *can* make the code self-explanatory by renaming or restructuring, do that first — comment only what the code genuinely cannot say.
- Flag intent that is still provisional (a workaround awaiting a fix) as a TODO rather than plain prose (see [03-warnings-and-todos.md](03-warnings-and-todos.md)).
