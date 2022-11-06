FROM node:18.9.0-alpine3.16

ENV USER my_web_sample
ENV HOST_USER keiju
ENV HOME /home/${USER}
ENV LANG C.UTF-8

RUN apk update && apk add --no-cache shadow sudo tzdata starship \
  && cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && apk del tzdata \
  && useradd -m ${USER} -u 1001 \
  && useradd ${HOST_USER} -u 1002 \
  && echo "my_web_sample:my_web_sample" | chpasswd && echo "my_web_sample ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
  && echo "Set disable_coredump false" >> /etc/sudo.conf \
  && echo "root:root" | chpasswd
RUN mv /usr/local/lib/node_modules /usr/local/lib/node_modules.tmp \
  && mv /usr/local/lib/node_modules.tmp /usr/local/lib/node_modules \
  && npm i -g npm@^8.19.3
#DEV
RUN apk add --no-cache bash curl git vim
WORKDIR /home/my_web_sample
# RUN sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --yes

USER ${USER}
WORKDIR ${HOME}/app
CMD [ "bash" ]