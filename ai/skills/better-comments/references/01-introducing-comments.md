# 01. Introducing Comments

Comments are at best a necessary evil and at worst actively harmful. Every comment is a small admission that the code could not express its own intent — so before writing one, first try to make the comment unnecessary.

## Contents

- [01. Introducing Comments](#01-introducing-comments)
  - [Contents](#contents)
  - [Comments do not make up for bad code](#comments-do-not-make-up-for-bad-code)
  - [The best comment is the one you avoided writing](#the-best-comment-is-the-one-you-avoided-writing)
  - [Comments lie because they are not executed](#comments-lie-because-they-are-not-executed)
  - [Comments do not redeem unclear code](#comments-do-not-redeem-unclear-code)
  - [Rules of thumb](#rules-of-thumb)

## Comments do not make up for bad code

The proper use of a comment is to compensate for our failure to express ourselves in code. When tempted to comment, treat it as a signal to refactor first: rename a variable, extract a function, or hoist a cryptic expression into a well-named value. Clear code needs no narration.

**Bad:** a comment explains a cryptic conditional.

```powershell
# eligible if active for 90+ days and not flagged
if ($u.Status -eq 'Active' -and ((Get-Date) - $u.Since).Days -ge 90 -and -not $u.IsFlagged) {
    Approve-Account $u
}
```

**Good:** extract well-named variables so the condition reads itself.

```powershell
$isActive    = $u.Status -eq 'Active'
$tenureDays  = ((Get-Date) - $u.Since).Days
$isSeasoned  = $tenureDays -ge 90
$isEligible  = $isActive -and $isSeasoned -and -not $u.IsFlagged

if ($isEligible) {
    Approve-Account $u
}
```

## The best comment is the one you avoided writing

A magic value annotated by a comment is still a magic value. Name it instead. The name lives in the code, travels with it, and cannot drift out of sync.

**Bad:** a comment explains a bare CIDR block.

```hcl
resource "aws_security_group_rule" "office_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["203.0.113.0/24"] # corporate office network
  security_group_id = var.security_group_id
}
```

**Good:** a named `local` makes the intent self-documenting.

```hcl
locals {
  corporate_office_cidr = "203.0.113.0/24"
}

resource "aws_security_group_rule" "office_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [local.corporate_office_cidr]
  security_group_id = var.security_group_id
}
```

## Comments lie because they are not executed

Code is compiled, run, and tested; comments are none of these. Nothing forces a comment to stay true, so over time it rots. The further a comment drifts from the code it describes, the more likely it is to mislead — and a confidently wrong comment is worse than no comment at all (see [06-misleading-and-confusing.md](06-misleading-and-confusing.md)). Prefer expressing facts in code, where the compiler and tests keep them honest.

## Comments do not redeem unclear code

You cannot annotate your way out of a mess. A comment perched on top of tangled logic does not untangle it; it merely apologizes for it. If a block needs a paragraph to be understood, the block — not the prose — is the defect. Fix the code.

This chapter is about the philosophy of *whether* to comment. The specific cases where a comment genuinely earns its place — and the categories that never do — belong to later chapters: legitimate intent ([02-context-and-intent.md](02-context-and-intent.md)), warnings and TODOs ([03-warnings-and-todos.md](03-warnings-and-todos.md)), redundant noise ([05-redundancy-and-noise.md](05-redundancy-and-noise.md)), and history that belongs in version control ([07-version-control-vs-code.md](07-version-control-vs-code.md)).

## Rules of thumb

- When you feel the urge to comment, first try to refactor the code so the comment becomes unnecessary.
- Replace explanatory comments with intention-revealing names: extracted variables, functions, and `local` values.
- Treat every surviving comment as a maintenance liability that no compiler or test will keep honest.
- Never use a comment to excuse code you could have made clearer.
- A comment you found a way *not* to write is the best comment of all.
