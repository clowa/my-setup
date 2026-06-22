# 04. Professional Standards

Some comments are not just allowed but expected: legal headers on source files and documentation comments on public surfaces. These earn their place because they serve a reader outside the codebase. Keep them lean and put them only where the public boundary actually is.

## Contents

- [04. Professional Standards](#04-professional-standards)
  - [Contents](#contents)
  - [Legal / license headers](#legal--license-headers)
  - [Document the public surface](#document-the-public-surface)
  - [PowerShell comment-based help](#powershell-comment-based-help)
  - [Terraform variable and output descriptions](#terraform-variable-and-output-descriptions)
  - [Don't document obvious private code](#dont-document-obvious-private-code)
  - [Rules of thumb](#rules-of-thumb)

## Legal / license headers

A license header states the license and copyright, then stops. Reference a standard license by its SPDX identifier instead of pasting its full text; the canonical text lives in a `LICENSE` file at the repository root.

**Bad:**

```powershell
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# ... 15 more lines of the full MIT text pasted into every file ...
```

**Good:**

```powershell
# Copyright (c) 2026 Teqwerk GmbH
# SPDX-License-Identifier: MIT
```

## Document the public surface

Documentation comments describe a contract for callers who never read the implementation: what to pass, what comes back, how to invoke it. They belong on exported functions, published modules, and module inputs and outputs, not on every line. Documenting internals is noise; see [05-redundancy-and-noise.md](05-redundancy-and-noise.md).

## PowerShell comment-based help

An exported function with no help is invisible to `Get-Help` and to anyone trying to call it. Supply `.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE`, and `.OUTPUTS`.

**Bad:**

```powershell
function New-StorageContainer {
    # exported, but callers have no contract to read
    param(
        [Parameter(Mandatory)][string]$AccountName,
        [Parameter(Mandatory)][string]$ContainerName
    )
    throw [System.NotImplementedException]::new()
}
Export-ModuleMember -Function New-StorageContainer
```

**Good:**

```powershell
function New-StorageContainer {
    <#
    .SYNOPSIS
        Creates a blob container in an existing storage account.
    .DESCRIPTION
        Creates the container if it does not already exist and returns its
        object. Idempotent: existing containers are returned as-is.
    .PARAMETER AccountName
        Name of the target storage account.
    .PARAMETER ContainerName
        Name of the container to create. Must be DNS-compliant and lowercase.
    .EXAMPLE
        New-StorageContainer -AccountName 'stprod001' -ContainerName 'logs'
    .OUTPUTS
        Microsoft.Azure.Storage.Blob.CloudBlobContainer
    #>
    param(
        [Parameter(Mandatory)][string]$AccountName,
        [Parameter(Mandatory)][string]$ContainerName
    )
    throw [System.NotImplementedException]::new()
}
Export-ModuleMember -Function New-StorageContainer
```

## Terraform variable and output descriptions

A module is a public API. Every `variable` and `output` is part of its contract, so each gets a `description` stating intent and constraints the type alone cannot convey.

**Bad:**

```hcl
variable "retention_days" {
  type = number
}

output "container_id" {
  value = azurerm_storage_container.this.id
}
```

**Good:**

```hcl
variable "retention_days" {
  type        = number
  description = "Days to retain blobs before lifecycle deletion. Set 0 to disable expiry."
  default     = 30
}

output "container_id" {
  description = "Resource ID of the created storage container, for use in role assignments."
  value       = azurerm_storage_container.this.id
}
```

Pair these with a module-level `README.md` showing a usage example; tooling like `terraform-docs` generates input and output tables straight from the `description` fields.

## Don't document obvious private code

Help blocks and descriptions are for the public boundary. A private helper that is never exported needs a clear name, not a doc comment that restates it.

```powershell
# unexported internal helper - no comment-based help needed
function Get-NormalizedName {
    param([string]$Name)
    return $Name.Trim().ToLowerInvariant()
}
```

## Rules of thumb

- State the license (prefer an SPDX identifier) and copyright only; never paste full license text into source files.
- Treat every exported function and every module `variable`/`output` as a public contract that requires documentation.
- Use complete PowerShell comment-based help: `.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE`, `.OUTPUTS`.
- Write a `description` for every Terraform input and output; capture constraints the type cannot express.
- Skip doc comments on internal helpers and obviously private code; documenting everything is noise (see [05-redundancy-and-noise.md](05-redundancy-and-noise.md)).
