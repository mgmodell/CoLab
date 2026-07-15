FROM docker.io/ubuntu:22.04

RUN apt-get update && apt-get upgrade -y && \
  apt-get -y install --fix-missing \
  autoconf \
  bison \
  bash \
  build-essential \
  curl \
  gettext \
  git \
  imagemagick \
  libdb-dev \
  libffi-dev \
  libgdbm-dev \
  libvips \
  libncurses-dev \
  libssl-dev \
  libreadline-dev \
  libmysqlclient-dev \
  libyaml-dev \
  libsecret-1-dev \
  make \
  mysql-client \
  ruby-build \
  tmux \
  vim \
  zlib1g-dev \
  zsh

RUN apt-get autoremove && \
    apt-get clean

ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd -g ${USER_GID} colab && \
  useradd -u ${USER_UID} --no-log-init -rm -d /home/colab -s /bin/zsh -g colab colab

USER colab

WORKDIR /home/colab

RUN curl -fsSL https://mise.jdx.dev/install.sh | sh
ENV PATH="/home/colab/src/app/node_modules/.bin:/home/colab/.local/share/mise/shims:/home/colab/.local/bin:$PATH"
RUN mkdir -p /home/colab/.local/share/mise && \
  # echo "export PATH=/home/colab/.local/bin:$PATH" >> ~/.zshrc && \
  printf 'bundler\nforeman\nrubocop\n' >> ~/.default-gems

RUN echo "export S3_BUCKET_NAME=colab-dev" >> ~/.bashrc &&\
  echo "export AWS_ACCESS_KEY_ID=XXXXXXX" >> ~/.bashrc &&\
  echo "export AWS_SECRET_ACCESS_KEY=XXXXXXX" >> ~/.bashrc &&\
  echo "export AWS_REGION=ap-northeast-2" >> ~/.bashrc &&\
  echo "export DISPLAY=:0" >> ~/.bashrc &&\
  echo "export LIBGL_ALWAYS_INDIRECT=1" >> ~/.bashrc && \
  echo "export DRIVER=docker" >> ~/.bashrc

# USER colab

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

#Set up the app materials
RUN sed -i 's/(git)/(\ngit\n\tmise\n\tbundler\n\trails\n\tyarn\n\trake\n\t)/g' ~/.zshrc
RUN grep -qxF 'eval "$(~/.local/bin/mise activate zsh)"' ~/.zshrc || \
  echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc
RUN grep -qxF 'eval "$(~/.local/bin/mise activate bash)"' ~/.bashrc || \
  echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
RUN mkdir -p /home/colab/src/app
COPY --chown=colab:colab containers/dev_entrypoint.sh /home/colab/src/entrypoint.sh
WORKDIR /home/colab/src/app
RUN mise settings add idiomatic_version_file_enable_tools ruby

# Trust all mise configs so managed tools are activated in every context
# (non-interactive postCreateCommand, interactive shells, and mise exec subprocesses)
# without requiring an explicit `mise trust` call to succeed first.
ENV MISE_TRUST_ALL=1

ENV DRIVER=docker
ENV COLAB_DB=db
ENV COLAB_DB_PORT=3306


# ENTRYPOINT  ["/home/colab/src/entrypoint.sh"]
# CMD -r
