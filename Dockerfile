ARG ALPINE_VERSION=3.20

FROM python:3.11.9-alpine${ALPINE_VERSION} as builder

ARG AWS_CLI_VERSION=2.17.16

RUN apk add --no-cache git unzip groff build-base libffi-dev cmake
RUN git clone --single-branch --depth 1 -b ${AWS_CLI_VERSION} https://github.com/aws/aws-cli.git

WORKDIR /aws-cli
RUN ./configure --with-install-type=portable-exe --with-download-deps
RUN make
RUN make install

# reduce image size: remove autocomplete and examples
RUN rm -rf \
    /usr/local/lib/aws-cli/aws_completer \
    /usr/local/lib/aws-cli/awscli/data/ac.index \
    /usr/local/lib/aws-cli/awscli/examples
RUN find /usr/local/lib/aws-cli/awscli/data -name completions-1*.json -delete
RUN find /usr/local/lib/aws-cli/awscli/botocore/data -name examples-1.json -delete
RUN (cd /usr/local/lib/aws-cli; for a in *.so*; do test -f /lib/$a && rm $a; done)

FROM ubuntu:latest
COPY --from=builder /usr/local/lib/aws-cli/ /usr/local/lib/aws-cli/
RUN ln -s /usr/local/lib/aws-cli/aws /usr/local/bin/aws

ARG USERNAME=developer
ARG GROUPNAME=developer
ARG UID=1002
ARG GID=1002
ARG HOME=/home/${USERNAME}
ARG TERRAFORM_VERSION=1.9.2
ENV PATH=${HOME}/.local/bin:$PATH
ENV LANG ja_JP.UTF-8

# Install basic packages
RUN apt-get update && apt-get install -y \
    tzdata \
    curl \
    unzip \
    git \
    sudo \
    vim \
    build-essential \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    libwebkit2gtk-4.1-dev \
    wget \
    file \
    libxdo-dev \
    libssl-dev \
    libayatana-appindicator3-dev \
    librsvg2-dev \
    && rm -rf /var/lib/apt/lists/*

# タイムゾーンを日本時間に設定
RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    echo "Asia/Tokyo" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash - \
    && apt-get install -y nodejs

# add golang
RUN apt-get update && apt-get install -y golang-go

# add rust
RUN apt-get update && apt-get install -y curl gcc && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# add python
RUN apt-get update && apt-get install -y python3 python3-pip && curl -sSL https://install.python-poetry.org | python3 - && poetry completions bash >> ~/.bash_completion && poetry config virtualenvs.in-project true

# Install Docker
RUN install -m 0755 -d /etc/apt/keyrings \
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

RUN usermod -aG docker $USERNAME

RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  &&  mv terraform /usr/bin/terraform

RUN sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --yes

RUN wget https://github.com/nushell/nushell/releases/download/0.96.1/nu-0.96.1-x86_64-unknown-linux-gnu.tar.gz \
  && tar -xvf nu-0.96.1-x86_64-unknown-linux-gnu.tar.gz \
  && mv nu-0.96.1-x86_64-unknown-linux-gnu/nu /usr/local/bin/nu \
  && rm -rf nu-0.96.1-x86_64-unknown-linux-gnu.tar.gz nu-0.96.1-x86_64-unknown-linux-gnu

RUN chown -R ${USERNAME}:${GROUPNAME} ${HOME} && chmod -R 755 ${HOME}

CMD [ "bash" ]