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

# Install Java
RUN apt-get update && apt-get install -y openjdk-21-jdk

# Install Docker
RUN apt-get update && apt-get install -y ca-certificates curl gnupg \
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && chmod a+r /etc/apt/keyrings/docker.gpg

RUN echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt-get update \
    && apt-get install -y docker-ce docker-ce-cli

# Create user and set permissions
RUN groupadd -g ${GID} ${GROUPNAME} \
    && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN gpasswd -a ${USERNAME} docker

RUN sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --yes

RUN echo '. ~/.bashrc' >> ~/.profile \
  && echo 'eval "$(starship init bash)"' >> ~/.bashrc \
  && echo "alias ll='ls -l'" >> ~/.bashrc \
  && echo "alias la='ls -la'" >> ~/.bashrc \
  && echo "alias l='ls -CF'" >> ~/.bashrc \
  && echo 'source ~/.bash_aliases' >> ~/.bashrc \
  && echo 'source ~/.bash_functions' >> ~/.bashrc \
  && echo 'export JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")' >> ~/.bashrc \
  && echo "export JAVA_HOME=$JAVA_HOME" >> ~/.bashrc \
  && echo "newgrp docker" >> ~/.bashrc
COPY .bash_aliases ${HOME}/
COPY .bash_functions ${HOME}/
COPY .vimrc ${HOME}/


RUN chown -R ${USERNAME}:${GROUPNAME} ${HOME} && chmod -R 755 ${HOME}

CMD [ "bash" ]