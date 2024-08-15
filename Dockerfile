FROM ubuntu:latest

ARG USERNAME=developer
ARG GROUPNAME=developer
ARG UID=1710
ARG GID=1710
ARG HOME=/home/${USERNAME}
ENV LANG C.UTF-8
ENV PATH=${HOME}/.local/bin:$PATH

# Install basic packages
RUN apt-get update && apt-get install -y \
    curl \
    git \
    sudo \
    vim \
    build-essential \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash - \
    && apt-get install -y nodejs

# Install Python
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && . $HOME/.cargo/env

# Install Docker CLI
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - \
    && add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable" \
    && apt-get update && apt-get install -y docker-ce-cli

# Install VS Code Server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Create user and set permissions
RUN groupadd -g ${GID} ${GROUPNAME} \
    && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set up user environment
USER ${USERNAME}
WORKDIR ${HOME}
RUN mkdir -p ${HOME}/.local/bin

# Copy configuration files
COPY .bash_aliases ${HOME}/
COPY .bash_functions ${HOME}/
COPY .vimrc ${HOME}/

RUN sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --yes

RUN chown -R ${USERNAME}:${GROUPNAME} ${HOME} && chmod -R 755 ${HOME}

CMD [ "bash" ]