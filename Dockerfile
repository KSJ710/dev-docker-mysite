FROM node:current-alpine3.16

ARG USER_NAME=template
ARG GROUP_NAME=template
ARG UID=1710
ARG GID=1710
ARG HOME=/home/${USER_NAME}
ARG LANG=C.UTF-8
ENV LANG ${LANG}

RUN apk update && apk add --no-cache shadow sudo tzdata \
  && cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && apk del tzdata \
  && groupadd -g ${GID} ${GROUP_NAME} \
  && useradd -m -u ${UID} -g ${GID} ${USER_NAME}  \
  && echo "${USER_NAME}:${GROUP_NAME}" | chpasswd && echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
  && echo "Set disable_coredump false" >> /etc/sudo.conf \
  && echo "root:root" | chpasswd
RUN mv /usr/local/lib/node_modules /usr/local/lib/node_modules.tmp \
  && mv /usr/local/lib/node_modules.tmp /usr/local/lib/node_modules \
  && npm i -g npm@^9.6.5
#DEV
RUN apk add --no-cache bash curl git vim starship less
# RUN sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --yes

CMD [ "bash" ]