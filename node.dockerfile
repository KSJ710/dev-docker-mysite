FROM node:current-alpine3.16

ARG USERNAME=my_web_sample
ARG GROUPNAME=my_web_sample
ARG UID=1001
ARG GID=1001
ARG HOME=/home/${USERNAME}
ENV LANG C.UTF-8

RUN apk update && apk add --no-cache shadow sudo tzdata \
  && cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && apk del tzdata \
  && groupadd -g ${GID} ${GROUPNAME} \
  && useradd -m -u ${UID} -g ${GID} ${USERNAME}  \
  && echo "${USERNAME}:${GROUPNAME}" | chpasswd && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
  && echo "Set disable_coredump false" >> /etc/sudo.conf \
  && echo "root:root" | chpasswd
RUN mv /usr/local/lib/node_modules /usr/local/lib/node_modules.tmp \
  && mv /usr/local/lib/node_modules.tmp /usr/local/lib/node_modules \
  && npm i -g npm@^9.6.5
#DEV
RUN apk add --no-cache bash curl git vim starship

# WORKDIR /home/my_web_sample
# RUN sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --yes

# USER ${USERNAME}
# WORKDIR ${HOME}/app
CMD [ "bash" ]