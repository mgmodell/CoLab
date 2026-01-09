FROM docker.io/ubuntu:22.04

RUN apt-get update && apt-get upgrade -y && \
  apt-get -y install --fix-missing \
  autoconf \
  bash \
  build-essential \
  curl \
  gettext \
  git \
  imagemagick \
  libvips \
  libssl-dev \
  libreadline-dev \
  libmysqlclient-dev \
  libyaml-dev \
  libsecret-1-dev \
  make \
  mysql-client \
  ruby-build \
  vim \
  zlib1g-dev \
  zsh

RUN apt-get autoremove && \
    apt-get clean

RUN groupadd -r colab && \
  useradd -u 501 --no-log-init -rm -d /home/colab -s /bin/zsh -g colab colab

USER colab

WORKDIR /home/colab

RUN curl -fsSL https://mise.jdx.dev/install.sh | sh
ENV PATH="/home/colab/.local/bin:$PATH"
RUN mkdir -p /home/colab/.local/share/mise && \
  echo 'eval "$(~/.local/bin/mise activate zsh)"' >> /home/colab/.zshrc && \
  # echo "export PATH=/home/colab/.local/bin:$PATH" >> ~/.zshrc && \
  echo "bundler \n foreman \n rubocop" >> ~/.default-gems

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
RUN mkdir -p /home/colab/src/app
COPY containers/dev_entrypoint.sh /home/colab/src/entrypoint.sh
WORKDIR /home/colab/src/app
RUN mise trust /home/colab/src/app/mise.toml && \
  mise settings add idiomatic_version_file_enable_tools ruby

ENV DRIVER=docker
ENV COLAB_DB=db
ENV COLAB_DB_PORT=3306


# ENTRYPOINT  ["/home/colab/src/entrypoint.sh"]
# CMD -r
