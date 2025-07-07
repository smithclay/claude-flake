# Docker MVP for Phase 2A - Single-stage, basic functionality
# Ubuntu base image for better compatibility
FROM ubuntu:22.04

# Install dependencies and Nix package manager
RUN apt-get update && apt-get install -y \
    curl \
    git \
    sudo \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Install Nix package manager
RUN curl -L https://nixos.org/nix/install | sh -s -- --daemon && \
    . /etc/profile.d/nix.sh

# Enable flakes support and configure Nix
RUN mkdir -p /etc/nix && \
    echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf && \
    echo "trusted-users = root claude" >> /etc/nix/nix.conf

# Copy entrypoint script and make it executable (as root)
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh && \
    chown root:root /usr/local/bin/entrypoint.sh

# Create directories for persistent volumes (as root)
RUN mkdir -p /workspace

# Create user for workspace with proper shell
RUN adduser --disabled-password --gecos "" claude && \
    mkdir -p /home/claude/.config && \
    chown -R claude:claude /home/claude && \
    chown -R claude:claude /workspace
USER claude
WORKDIR /home/claude

# Set environment variables
ENV PATH="/nix/var/nix/profiles/default/bin:/home/claude/.nix-profile/bin:$PATH"
ENV USER=claude
ENV HOME=/home/claude
ENV NIX_PATH="/nix/var/nix/profiles/per-user/root/channels"

# Install Claude-Flake via the new architecture
# This uses the current flake.nix with home-manager integration
# Source Nix environment and run setup
RUN . /etc/profile.d/nix.sh && \
    nix run github:smithclay/claude-flake || echo "Warning: Claude-Flake setup encountered issues"

# Create additional directories for persistent volumes
RUN mkdir -p /home/claude/.config/claude-flake /home/claude/.cache/nix /home/claude/.local/share && \
    chown -R claude:claude /home/claude/.config /home/claude/.cache /home/claude/.local

# Set working directory to workspace for volume mounting
WORKDIR /workspace

# Add volume declarations for persistence
VOLUME ["/workspace", "/home/claude/.config", "/home/claude/.cache/nix", "/home/claude/.local/share"]

# Use entrypoint script with proper shell
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]