FROM node:18.9.0-alpine3.16

ENV USER my_web_sample
ENV HOME /home/${USER}
ENV LANG C.UTF-8

RUN apk update && apk add --no-cache shadow sudo tzdata \
  && cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && apk del tzdata \
  && useradd -m ${USER} && usermod -u 1001 ${USER} && groupmod -g 1001 ${USER} \
  && echo "my_web_sample:my_web_sample" | chpasswd && echo "my_web_sample ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
  && echo "Set disable_coredump false" >> /etc/sudo.conf \
  && echo "root:root" | chpasswd
RUN mv /usr/local/lib/node_modules /usr/local/lib/node_modules.tmp \
  && mv /usr/local/lib/node_modules.tmp /usr/local/lib/node_modules \
  && npm i -g npm@^8.6.0
#DEV
RUN apk add --no-cache bash curl git vim
WORKDIR /home/sample
RUN sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --yes

USER ${USER}
WORKDIR ${HOME}/app
CMD [ "bash" ]