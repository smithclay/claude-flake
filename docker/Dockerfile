# Docker MVP for Phase 2A - Single-stage, basic functionality
# Ubuntu 20.04 base image for better ARM64 emulation compatibility
FROM ubuntu:20.04

# Configure environment for QEMU stability
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Install dependencies and Nix package manager
RUN apt-get update && apt-get install -y \
    --no-install-recommends \
    --fix-missing \
    ca-certificates \
    curl \
    git \
    sudo \
    xz-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* /var/tmp/* \
    && update-ca-certificates

# Create claude user with real home directory first
RUN adduser --disabled-password --gecos "" --shell /bin/bash claude && \
    mkdir -p /home/claude /workspace && \
    chown -R claude:claude /home/claude /workspace

# Install Nix using Determinate Systems installer for containers
RUN curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install linux \
    --init none \
    --extra-conf "experimental-features = nix-command flakes" \
    --extra-conf "filter-syscalls = false" \
    --extra-conf "sandbox = false" \
    --no-confirm

# Configure Nix for claude user ownership
RUN chown -R claude:claude /nix

# Copy entrypoint script and make it executable (need to be root for this)
USER root
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Switch back to claude user for remaining operations
USER claude
WORKDIR /home/claude

# Set environment variables for claude user
ENV PATH="/nix/var/nix/profiles/default/bin:/home/claude/.nix-profile/bin:$PATH"
ENV USER=claude
ENV HOME=/home/claude

# Install home-manager first, then set up Claude-Flake using the dynamic setup
RUN . /nix/var/nix/profiles/default/etc/profile.d/nix.sh && \
    nix profile install nixpkgs#home-manager && \
    export PATH="$HOME/.nix-profile/bin:$PATH" && \
    nix run github:smithclay/claude-flake --accept-flake-config

# Verify that claude command is available after setup
RUN . /home/claude/.nix-profile/etc/profile.d/nix.sh && \
    . /home/claude/.config/claude-flake/loader.sh && \
    claude --version

# Create additional directories for persistent volumes
RUN mkdir -p /home/claude/.config/claude-flake /home/claude/.cache/nix /home/claude/.local/share

# Set working directory to workspace for interactive use
WORKDIR /workspace

# Add volume declarations for persistence
VOLUME ["/workspace", "/home/claude/.config", "/home/claude/.cache/nix", "/home/claude/.local/share"]

# Use entrypoint script with proper shell
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]