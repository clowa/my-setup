# Overview

## Installing skills from [skills.sh](https://skills.sh)

Use this when you don't want `npx` / Node installed locally. Replace `<REPO_URL>`
and `<SKILL_NAME>` with the values from the install instructions on
[skills.sh](https://skills.sh).

```bash
mkdir -p ~/github/my-setup/.agents
 
docker run --rm \
  -v "$HOME/github/my-setup/ai/skills:/Users/cahlers/github/my-setup/ai/skills" \
  -v "$HOME/github/my-setup/.agents:/root/.agents" \
  -v "$HOME/.claude:/root/.claude" \
  -w /root \
  node:22-alpine \
  sh -c "apk add --no-cache git && npx -y skills add <REPO_URL> --skill <SKILL_NAME> --yes --global"
```

Verify with `ls -l ~/github/my-setup/ai/skills/<SKILL_NAME>` (follows symlinks).

## Lessons learned

- **Symlinks inside bind mounts resolve against the container's filesystem, not
  the host's.** My `~/.claude/skills` is a symlink to
  `/Users/cahlers/github/my-setup/ai/skills`. Inside the container that target
  path doesn't exist, so the symlink dangles and `mkdir` on it returns `ENOTDIR`.
  Fix: bind-mount the symlink's *target* at the same absolute path the symlink
  points to (`-v "$HOME/github/my-setup/ai/skills:/Users/cahlers/github/my-setup/ai/skills"`),
  so the symlink resolves identically on both sides of the mount boundary.
- **The CLI writes skills to `~/.agents/skills/` and symlinks each agent dir
  to it using a *relative* path.** For `azure-cost` the link is
  `../../.agents/skills/azure-cost`, computed from inside the container. On the
  host that relative path resolves to `~/github/my-setup/.agents/skills/azure-cost`,
  not `~/.agents/skills/azure-cost`. Mounting `~/github/my-setup/.agents` as
  `/root/.agents` makes the container's view of `.agents` and the host's relative
  resolution agree — and has the nice side effect of keeping skill files inside
  the dotfiles repo where they can be version-controlled or gitignored as needed.
- **Bind-mount everything the CLI writes to, or it disappears with the
  container.** That means `~/.claude` (the symlink container), the skills
  target dir inside the repo, and `.agents` (the real install root). Missing
  any one of these means the install "succeeds" inside the container but leaves
  no trace on the host.
