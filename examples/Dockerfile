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

RUN mkdir -p ~/.config/nix && \
    echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

RUN . /home/clay/.nix-profile/etc/profile.d/nix.sh && \
    nix run home-manager -- switch --flake github:smithclay/genai-nix-flake#base

RUN . /home/clay/.nix-profile/etc/profile.d/nix.sh && \
    nix run home-manager -- switch --flake github:smithclay/genai-nix-flake#claude-taskmaster

CMD ["/bin/bash"]