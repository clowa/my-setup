# Overview

This folder contains my personal OpenCode configuration and custom AI Agents stuff.

To setup these files and symlink them to your OpenCode configuration. you can use the provided Setup script in this folder.

I try to keep this readme up to data with pages that helped my understanding of OpenCode and AI Agents in general and set thing up properly - see the [Resources section](#resources) below.

## Run as container

```bash
## Using apple container
## or replace container with docker
container run -it \
    -v ~/.local/share/opencode:/root/.local/share/opencode \
    -v ~/.config/opencode:/root/.config/opencode \
    -v ~/github/my-setup/opencode:/root/.config/opencode \
    -v $(PWD):/workspace \
    -w /workspace \
    -p 1455:1455 \
    ghcr.io/anomalyco/opencode  
```

> [!TIP]
> Expose Port 1455 to the host, to use support interactive logins to model providers.

## Resources

- [OpenCode Configuration](https://opencode.ai/docs/config/#_top)
- [Vercel Skills Leaderboard and Repository](https://skills.sh)
