# 09. Poor Communication Style

Even a warranted comment fails if it communicates poorly. Write for a stranger reading the code in a year, not for yourself today.

## Contents

- [09. Poor Communication Style](#09-poor-communication-style)
  - [Contents](#contents)
  - [Mumbling](#mumbling)
  - [Too Much Information](#too-much-information)
  - [Inobvious Connection](#inobvious-connection)
  - [Nonlocal Information](#nonlocal-information)
  - [Unprofessional Language](#unprofessional-language)
  - [Rules of thumb](#rules-of-thumb)

## Mumbling

A comment only the author understands is no comment at all. Say enough that the reader does not have to reconstruct your reasoning.

**Bad:**

```powershell
function Get-RetryDelay {
    param([int]$Attempt)
    # if it fails again do the thing
    return [math]::Pow(2, $Attempt)
}
```

**Good:**

```powershell
function Get-RetryDelay {
    param([int]$Attempt)
    # Exponential backoff: delay doubles each attempt to avoid
    # hammering a recovering service.
    return [math]::Pow(2, $Attempt)
}
```

## Too Much Information

A comment is not a place for historical essays, pasted RFC excerpts, or backstory. Keep only the part the reader needs at this line.

**Bad:**

```hcl
# Originally we used a single subnet, but back in 2021 the network team
# (see the old wiki, since deleted) wanted everything flat. Then RFC 1918
# defines 10.0.0.0/8, 172.16.0.0/12, and 192.168.0.0/16 as private ranges,
# and after a long thread we picked /24 because someone said /16 was wasteful.
resource "aws_subnet" "app" {
  cidr_block = "10.0.1.0/24"
}
```

**Good:**

```hcl
# /24 caps this tier at 254 hosts, matching our autoscaling ceiling.
resource "aws_subnet" "app" {
  cidr_block = "10.0.1.0/24"
}
```

## Inobvious Connection

The reader must see how the comment relates to the code. Reuse the terms that appear in the code; never introduce names the code does not contain.

**Bad:**

```powershell
# the magic number accounts for the fudge factor
$timeout = 270
```

**Good:**

```powershell
# 270s = the gateway's 300s hard limit minus a 30s safety margin.
$timeout = 270
```

## Nonlocal Information

Keep a comment local to the code it describes. One that documents a global default, another module, or a value defined elsewhere goes stale the moment that distant thing changes. If you cannot keep it local, state intent rather than restate the remote value.

**Bad:**

```hcl
variable "instance_type" {
  # The platform default is t3.medium, set in the root module's locals;
  # staging uses t3.small to save cost.
  type    = string
  default = "t3.small"
}
```

**Good:**

```hcl
variable "instance_type" {
  # Smaller than production on purpose: staging trades capacity for cost.
  type    = string
  default = "t3.small"
}
```

## Unprofessional Language

Jokes, profanity, snark, and blame outlive the moment and embarrass the team. Say what the code does and why, not who you blame for it. For wider conduct, see [04-professional-standards.md](04-professional-standards.md).

**Bad:**

```powershell
# the networking team's garbage API returns 200 on errors, classic them
if ($response.body.status -ne 'ok') {
    throw "Upstream request failed"
}
```

**Good:**

```powershell
# Upstream returns HTTP 200 even on failure; the real status is in the body.
if ($response.body.status -ne 'ok') {
    throw "Upstream request failed"
}
```

## Rules of thumb

- Write for a stranger a year out, not for your present self.
- Keep comments local; describe the line you are next to, not a distant default that will drift. See [06-misleading-and-confusing.md](06-misleading-and-confusing.md) for stale comments.
- Reuse the code's own terms so the connection is obvious; never coin names the code lacks.
- Trim backstory and quotes down to the single WHY the reader needs now.
- Keep it professional: no jokes, profanity, snark, or blame.
