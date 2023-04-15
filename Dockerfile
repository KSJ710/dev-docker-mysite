FROM docker:23.0.3-alpine3.17

ARG USER=terraform
ARG HOME=/home/${USER}
ENV LANG C.UTF-8

RUN apk update && apk add --no-cache shadow sudo tzdata \
  && cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && apk del tzdata \
  && useradd -m ${USER}  \
  && echo "${USER}:${USER}" | chpasswd && echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
  && echo "Set disable_coredump false" >> /etc/sudo.conf \
  && echo "root:root" | chpasswd \
  && sudo groupadd docker && sudo usermod -aG docker ${USER}
RUN apk add --no-cache bash wget unzip git vim starship \
  && sudo wget https://releases.hashicorp.com/terraform/1.4.5/terraform_1.4.5_linux_amd64.zip \
  && sudo unzip terraform_1.4.5_linux_amd64.zip \
  && sudo mv terraform /usr/bin/terraform

# RUN sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --yes

# CMD [ "bash" ]