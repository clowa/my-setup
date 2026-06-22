# 08. Visual Clutter & Formatting

Comments are not page decoration. Banners, closing-block labels, and hand-aligned columns add visual weight without adding information. Let naming, small functions, and file structure carry the structure instead.

## Contents

- [08. Visual Clutter \& Formatting](#08-visual-clutter--formatting)
  - [Contents](#contents)
  - [Banner \& section-divider comments](#banner--section-divider-comments)
  - [Closing-block markers](#closing-block-markers)
  - [Over-formatted aligned columns](#over-formatted-aligned-columns)
  - [Rules of thumb](#rules-of-thumb)

## Banner & section-divider comments

A wall of `#######`, `======`, or box art used to chunk a file is noise. After a few screens the reader stops seeing banners, so they hide structure rather than reveal it. The structure they fake is better expressed by extracting functions (PowerShell) or splitting into well-named files such as `network.tf` and `dns.tf` (Terraform). A single divider marking one genuinely major boundary is fine; a row of them per section is not.

**Bad:**

```powershell
###############################################################
#                     HELPER FUNCTIONS                        #
###############################################################
$users = Get-Content ./users.json | ConvertFrom-Json
foreach ($u in $users) { Set-Mailbox -Identity $u.upn -Archive $true }

###############################################################
#                     MAIN EXECUTION                          #
###############################################################
Write-Output "Done"
```

**Good:**

```powershell
function Enable-UserArchive {
    param([string]$Path = './users.json')
    Get-Content $Path | ConvertFrom-Json |
        ForEach-Object { Set-Mailbox -Identity $_.upn -Archive $true }
}

Enable-UserArchive
Write-Output 'Done'
```

In Terraform, banners between blocks signal that one file is doing too much. Split by concern and let file names carry the sections.

**Bad:**

```hcl
# ============================ NETWORK ============================
resource "azurerm_virtual_network" "main" { name = "vnet-prod" }

# ============================== DNS ==============================
resource "azurerm_dns_zone" "main" { name = "example.com" }
```

**Good:** split by concern into separate files so the file names carry the sections.

`network.tf`:

```hcl
resource "azurerm_virtual_network" "main" {
  name = "vnet-prod"
}
```

`dns.tf`:

```hcl
resource "azurerm_dns_zone" "main" {
  name = "example.com"
}
```

## Closing-block markers

A `} # end function` or `# end foreach` comment is a symptom: the block grew long enough that the reader lost track of where it ends. The fix is not a label at the bottom; it is a shorter block. Extract the body into a named function so the opening line and the close fit on one screen. (For comments that merely restate the code, see [05-redundancy-and-noise.md](05-redundancy-and-noise.md).)

**Bad:**

```powershell
foreach ($vm in $vms) {
    # ... 40 lines of provisioning, tagging, and logging ...
} # end foreach $vm

function Invoke-Backup {
    # ... 60 lines ...
} # end function Invoke-Backup
```

**Good:**

```powershell
foreach ($vm in $vms) {
    Initialize-Vm $vm
    Add-VmTags $vm
}
```

Each loop body and function is short enough that no end-marker is needed; indentation and the name already tell the reader where it ends.

## Over-formatted aligned columns

Hand-aligned comment columns look tidy until the next edit. One longer line forces every neighbour to be re-padded, producing a noisy diff and a crooked block when the writer skips the realignment. Keep trailing comments single-spaced, or drop them when the name already explains the value (see [05-redundancy-and-noise.md](05-redundancy-and-noise.md)).

**Bad:**

```hcl
variable "sku"      { default = "Standard" }   # pricing tier
variable "replicas" { default = 3 }            # instance count
variable "region"   { default = "westeurope" } # primary region
```

**Good:**

```hcl
variable "sku" {
  default = "Standard"
}

variable "replica_count" {
  default = 3
}

variable "primary_region" {
  default = "westeurope"
}
```

## Rules of thumb

- Replace banners with structure: extract functions, or split into well-named files (`network.tf`, `dns.tf`).
- Reserve at most one plain divider for a genuinely major boundary; never a row of them.
- An end-of-block marker means the block is too long. Shorten or extract instead.
- Don't hand-align comment columns; alignment breaks on the next edit and pollutes diffs.
- Let indentation, names, and file layout carry structure so comments can carry intent (see [02-context-and-intent.md](02-context-and-intent.md)).
