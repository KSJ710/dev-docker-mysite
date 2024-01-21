FROM node:21.6-alpine3.18

ARG USERNAME=my_web_sample
ARG GROUPNAME=my_web_sample
ARG UID=1710
ARG GID=1710
ARG HOME=/home/${USERNAME}
ENV LANG C.UTF-8

RUN apk update && apk add --no-cache shadow sudo tzdata \
  && cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && apk del tzdata \
  && groupadd -g ${GID} ${GROUPNAME} \
  && useradd -m -u ${UID} -g ${GID} ${USERNAME}  \
  && echo "${USERNAME}:${GROUPNAME}" | chpasswd && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
  && echo "Set disable_coredump false" >> /etc/sudo.conf \
  && echo "root:root" | chpasswd

RUN npm i -g npm@^10.3.0
# dev
RUN apk add --no-cache bash curl git vim starship less

# WORKDIR /home/my_web_sample
# RUN sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --yes

# WORKDIR ${HOME}/app
CMD [ "bash" ]