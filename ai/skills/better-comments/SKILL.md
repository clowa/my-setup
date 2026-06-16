---
name: better-comments
description: Guidelines for writing better code comments, based on Clean Code principles — comment the WHY not the WHAT, prefer expressive code over comments, and remove redundant, misleading, or noisy comments. Use when writing, reviewing, cleaning up, or adding code comments, doc comments, or documentation, or when the user mentions improving comments.
---

# Better Comments

Write comments that earn their place. Guiding principle: **a comment should explain *why*, not restate *what* the code already says** — and the best comment is often the one you avoided by making the code clearer.

> Comments do not make up for bad code. Before writing one, try to make the code express the intent itself: better names, smaller functions, a named variable or local.

Examples in the chapters use PowerShell and Terraform (HCL), but the principles are language-agnostic.

## Decision flow — before writing a comment

1. **Can the code say this instead?** Rename, extract a function, or introduce a named variable/local. If yes → do that, don't comment (see [references/01-introducing-comments.md](references/01-introducing-comments.md) and [references/05-redundancy-and-noise.md](references/05-redundancy-and-noise.md)).
2. **Does the comment add something the code cannot?** Intent, a business/external constraint, a warning, public-API docs → keep it and make it a *good* comment.
3. **Will it still be true after the next change?** If it is likely to drift, it will rot and mislead — reconsider (see [references/06-misleading-and-confusing.md](references/06-misleading-and-confusing.md)).
4. **Is Git already tracking this?** History, authorship, old code → delete it (see [references/07-version-control-vs-code.md](references/07-version-control-vs-code.md)).

## When cleaning up existing comments — delete these

- Redundant / noise comments that restate the code → [references/05-redundancy-and-noise.md](references/05-redundancy-and-noise.md)
- Misleading or stale comments that contradict the code → [references/06-misleading-and-confusing.md](references/06-misleading-and-confusing.md)
- Commented-out code, changelogs, author bylines → [references/07-version-control-vs-code.md](references/07-version-control-vs-code.md)
- Banner art, `# end function` markers, ASCII separators → [references/08-visual-clutter-and-formatting.md](references/08-visual-clutter-and-formatting.md)
- Cryptic, bloated, or unprofessional wording → [references/09-communication-style.md](references/09-communication-style.md)

## Chapters

Read the relevant chapter for detail and bad/good examples:

| When you need to… | Read |
|---|---|
| Understand the philosophy: comments as a last resort | [references/01-introducing-comments.md](references/01-introducing-comments.md) |
| Write GOOD comments: context, intent, clarification | [references/02-context-and-intent.md](references/02-context-and-intent.md) |
| Flag risk or future work: warnings, TODOs, amplification | [references/03-warnings-and-todos.md](references/03-warnings-and-todos.md) |
| Document public APIs, licenses, and modules | [references/04-professional-standards.md](references/04-professional-standards.md) |
| Remove redundant and noise comments | [references/05-redundancy-and-noise.md](references/05-redundancy-and-noise.md) |
| Fix misleading, stale, or mandated comments | [references/06-misleading-and-confusing.md](references/06-misleading-and-confusing.md) |
| Stop duplicating what Git already tracks | [references/07-version-control-vs-code.md](references/07-version-control-vs-code.md) |
| Clean up banners, end-markers, and ASCII clutter | [references/08-visual-clutter-and-formatting.md](references/08-visual-clutter-and-formatting.md) |
| Improve unclear, bloated, or unprofessional wording | [references/09-communication-style.md](references/09-communication-style.md) |

## Golden rules

- **Why, not what.** The code shows *what*; a comment exists to explain *why*.
- **Prefer code over comments.** A good name beats a comment; an extracted function beats a block comment.
- **A comment is a liability.** It is not executed or tested, so it drifts from the code — keep only those that pay for their upkeep.
- **No duplication of Git.** Don't keep dead code, changelogs, or bylines in comments.
- **Document the public surface, not the obvious.** Doc comments belong on exported/published APIs, not on self-evident internal code.
- **Be professional.** Comments are read by colleagues and your future self — clear, concise, no snark.
