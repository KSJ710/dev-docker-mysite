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
RUN apk add --no-cache bash git vim starship
# RUN sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --yes

ENTRYPOINT ["/bin/bash"]

# CMD [ "bash" ]