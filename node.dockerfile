FROM node:17.0.1-alpine3.14

ENV USER mysite
ENV HOME /home/mysite
ENV LANG C.UTF-8

RUN apk update && apk add --no-cache shadow sudo tzdata \
  && cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && apk del tzdata \
  && useradd -m ${USER} && usermod -u 1001 ${USER} && groupmod -g 1001 ${USER} \
  && echo "mysite:mysite710" | chpasswd && echo "mysite ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
  && echo "Set disable_coredump false" >> /etc/sudo.conf \
  && echo "root:root710" | chpasswd
RUN mv /usr/local/lib/node_modules /usr/local/lib/node_modules.tmp \
  && mv /usr/local/lib/node_modules.tmp /usr/local/lib/node_modules \
  && npm i -g npm@^8.1.1
#DEV
RUN apk add --no-cache bash curl git vim
WORKDIR /home/mysite
RUN sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --yes

USER ${USER}
WORKDIR ${HOME}/app
CMD [ "bash" ]