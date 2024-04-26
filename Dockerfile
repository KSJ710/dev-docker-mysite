ARG ALPINE_VERSION=3.18

FROM python:3.11.4-alpine${ALPINE_VERSION} as builder

ARG AWS_CLI_VERSION=2.12.3

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

FROM docker:24.0.2-alpine${ALPINE_VERSION}
COPY --from=builder /usr/local/lib/aws-cli/ /usr/local/lib/aws-cli/
RUN ln -s /usr/local/lib/aws-cli/aws /usr/local/bin/aws

ARG USERNAME=terraform
ARG GROUPNAME=terraform
ARG UID=1710
ARG GID=1710
ARG HOME=/home/${USERNAME}
ARG TERRAFORM_VERSION=1.8.2
ENV LANG C.UTF-8

RUN apk update && apk add --no-cache shadow curl sudo tzdata \
  && cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && apk del tzdata \
  && groupadd -g ${GID} ${GROUPNAME} \
  && useradd -m -u ${UID} -g ${GID} ${USERNAME}  \
  && echo "${USERNAME}:${GROUPNAME}" | chpasswd && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
  && echo "Set disable_coredump false" >> /etc/sudo.conf \
  && echo "root:root" | chpasswd \
  && sudo groupadd docker && sudo usermod -aG docker ${USERNAME}
RUN apk add --no-cache git bash vim less wget bind-tools \
  && sudo wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && sudo unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && sudo mv terraform /usr/bin/terraform

RUN sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --yes
RUN echo "alias ll='ls -l'" >> ~/.bashrc \
  && echo "alias la='ls -la'" >> ~/.bashrc \
  && echo "alias l='ls -CF'" >> ~/.bashrc \
  && echo 'eval $(starship init bash)' >> ~/.bashrc
COPY .bash_aliases "/home/${USERNAME}/"
COPY .bash_functions "/home/${USERNAME}/"

CMD [ "bash" ]