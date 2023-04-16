ARG ALPINE_VERSION=3.17

FROM python:3.10-alpine${ALPINE_VERSION} as builder

ARG AWS_CLI_VERSION=2.11.11

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

FROM docker:23.0.3-alpine${ALPINE_VERSION}
COPY --from=builder /usr/local/lib/aws-cli/ /usr/local/lib/aws-cli/
RUN ln -s /usr/local/lib/aws-cli/aws /usr/local/bin/aws

ARG USER=terraform
ARG HOME=/home/${USER}
ARG TERRAFORM_VERSION=1.4.5
ENV LANG C.UTF-8

RUN apk update && apk add --no-cache shadow sudo tzdata \
  && cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && apk del tzdata \
  && useradd -m ${USER}  \
  && echo "${USER}:${USER}" | chpasswd && echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
  && echo "Set disable_coredump false" >> /etc/sudo.conf \
  && echo "root:root" | chpasswd \
  && sudo groupadd docker && sudo usermod -aG docker ${USER}
RUN apk add --no-cache git bash wget vim starship \
  && sudo wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && sudo unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && sudo mv terraform /usr/bin/terraform


# RUN sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --yes

# CMD [ "bash" ]