FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    sudo \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash clay && \
    echo "clay ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER clay
WORKDIR /home/clay

RUN curl -L https://nixos.org/nix/install | sh -s -- --no-daemon

ENV PATH="/home/clay/.npm-global/bin:/home/clay/.nix-profile/bin:$PATH"
ENV USER=clay
ENV HOME=/home/clay
ENV CLAUDE_FLAKE=/home/clay/workspace/claude-flake

RUN mkdir -p ~/.config/nix && \
    echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

RUN . /home/clay/.nix-profile/etc/profile.d/nix.sh && \
    nix run home-manager -- switch --flake github:smithclay/claude-flake#base

RUN . /home/clay/.nix-profile/etc/profile.d/nix.sh && \
    nix run home-manager -- switch --flake github:smithclay/claude-flake#claude-taskmaster

# Add claude-flake loader to existing shell files
# This provides all shell configuration without clobbering existing files
RUN echo '' >> ~/.bashrc && \
    echo '# Load Claude-Flake configuration' >> ~/.bashrc && \
    echo '[[ -r ~/.config/claude-flake/loader.sh ]] && source ~/.config/claude-flake/loader.sh' >> ~/.bashrc

RUN echo '' >> ~/.profile && \
    echo '# Load Claude-Flake configuration' >> ~/.profile && \
    echo '[[ -r ~/.config/claude-flake/loader.sh ]] && source ~/.config/claude-flake/loader.sh' >> ~/.profile

CMD ["/bin/bash"]