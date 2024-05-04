FROM mcr.microsoft.com/playwright

ARG USERNAME=my_web_sample
ARG GROUPNAME=my_web_sample
ARG UID=1710
ARG GID=1710
ARG HOME=/home/${USERNAME}
ENV LANG C.UTF-8

# Ubuntuのパッケージリストを更新し、必要なパッケージをインストール
RUN apt-get update && apt-get install -y --no-install-recommends sudo \
  && groupadd -g ${GID} ${GROUPNAME} \
  && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USERNAME} \
  && echo "${USERNAME}:${GROUPNAME}" | chpasswd && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
  && echo "Set disable_coredump false" >> /etc/sudo.conf \
  && echo "root:root" | chpasswd

# # npmのバージョン10.3.0をインストール
RUN npm i -g npm@^10.5.0

# # 開発に必要なツールをインストール
RUN apt-get install -y vim less

# # starshipプロンプトのインストール
RUN sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --yes

COPY .bash_profile ${HOME}/
COPY .bashrc ${HOME}/
COPY .vimrc ${HOME}/

# ユーザーのホームディレクトリに作業ディレクトリを設定
WORKDIR ${HOME}/app


CMD [ "bash" ]
