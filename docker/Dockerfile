# Docker MVP for Phase 2A - Single-stage, basic functionality
# Base image with Nix package manager
FROM nixos/nix:latest

# Enable flakes support and configure Nix
RUN echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf && \
    echo "trusted-users = root claude" >> /etc/nix/nix.conf

# Copy entrypoint script and make it executable (as root)
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh && \
    chown root:root /usr/local/bin/entrypoint.sh

# Create user for workspace with proper shell
RUN adduser -D -s /bin/bash claude && \
    mkdir -p /home/claude/.config && \
    chown -R claude:claude /home/claude
USER claude
WORKDIR /home/claude

# Set environment variables
ENV PATH="/home/claude/.nix-profile/bin:/home/claude/.local/state/nix/profiles/profile/bin:$PATH"
ENV USER=claude
ENV HOME=/home/claude

# Install Claude-Flake via the new architecture
# This uses the current flake.nix with home-manager integration
# Using || true to handle potential setup issues gracefully
RUN nix run github:smithclay/claude-flake || echo "Warning: Claude-Flake setup encountered issues"

# Create directories for persistent volumes
RUN mkdir -p /workspace /home/claude/.config/claude-flake /home/claude/.cache/nix /home/claude/.local/share && \
    chown -R claude:claude /workspace /home/claude/.config /home/claude/.cache /home/claude/.local

# Set working directory to workspace for volume mounting
WORKDIR /workspace

# Add volume declarations for persistence
VOLUME ["/workspace", "/home/claude/.config", "/home/claude/.cache/nix", "/home/claude/.local/share"]

# Use entrypoint script with proper shell
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]