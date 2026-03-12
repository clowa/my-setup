# Overview

This folder contains Dockerfiles for different sandboxes. They mainly contain the Opencode, but also include different tools depending on the sandbox. For example, the Kubernetes sandbox includes kubectl.

## Build & Run

> [!TIP]
> When using docker hardened images you have to authenticate with a docker hub account. Generate an API key (read-only is sufficient) and use it as the password when authenticating.
> Use the following command for apple containers `container registry login dhi.io`.

To build the images run a local build command from this folder and specify the Dockerfile you want to build. For example, to build the Kubernetes sandbox run:

```bash
container build -f Dockerfile.kubernetes -t clowa/opencode-kubectl .
```

To run this image, check witch volumes you need to mount. For example, for the Kubernetes sandbox you need to mount the kubeconfig file and the Opencode config and data folders:

```bash
container run -it \
    --name opencode \
    --rm \
    -v ~/.kube:/root/.kube \
    -v ~/.local/share/opencode:/root/.local/share/opencode \
    -v ~/.config/opencode:/root/.config/opencode \
    -v $(PWD):/workspace \
    -w /workspace \
    --memory 4G \
    clowa/opencode-kubectl:latest
```

This will open a shell in the container with the current directory mounted as /workspace. You can then run Opencode and kubectl commands as you would normally.
