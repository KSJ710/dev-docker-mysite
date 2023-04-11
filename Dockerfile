FROM hashicorp/packer:latest

ARG USER=packer
ARG HOME=/home/${USER}
ENV LANG C.UTF-8

RUN apk update && apk add --no-cache shadow sudo tzdata \
  && cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && apk del tzdata \
  && useradd -m ${USER}  \
  && echo "${USER}:${USER}" | chpasswd && echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
  && echo "Set disable_coredump false" >> /etc/sudo.conf \
  && echo "root:root" | chpasswd
RUN mv /usr/local/lib/node_modules /usr/local/lib/node_modules.tmp \
  && mv /usr/local/lib/node_modules.tmp /usr/local/lib/node_modules \
  && npm i -g npm@^8.19.3
#DEV
RUN apk add --no-cache bash curl git vim starship
# RUN sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --yes

CMD [ "bash" ]