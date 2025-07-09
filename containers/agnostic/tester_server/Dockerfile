FROM docker.io/ubuntu

RUN apt-get update && apt-get upgrade -y && \
  apt-get -y install \
  curl \
  imagemagick \
  libvips \
  make \
  ruby-build \
  vim \
  autoconf \
  gettext \
  git \
  bash \
  libmysqlclient-dev \
  libsecret-1-dev \
  libyaml-dev && \
  apt-get autoremove -y && \
  apt-get clean 

RUN groupadd -r colab && \
  useradd --no-log-init -rm -d /home/colab -s /bin/bash -g colab colab


WORKDIR /home/colab

USER colab
RUN curl -fsSL https://mise.jdx.dev/install.sh | sh
ENV PATH="/home/colab/.local/bin:$PATH"
RUN mkdir -p /home/colab/.local/share/mise && \
  # echo "export PATH=/home/colab/.local/bin:$PATH" >> /home/colab/.bashrc && \
  echo 'eval "$(~/.local/bin/mise activate bash)"' >> /home/colab/.bashrc && \
  mise activate --shims && \
  echo "bundler \n foreman \n" >> /home/colab/default-gems
# ENV PATH="/home/colab/.local/share/mise/shims:$PATH"

RUN echo "export S3_BUCKET_NAME=colab-dev" >> ~/.bashrc &&\
  echo "export AWS_ACCESS_KEY_ID=XXXXXXX" >> ~/.bashrc &&\
  echo "export AWS_SECRET_ACCESS_KEY=XXXXXXX" >> ~/.bashrc &&\
  echo "export AWS_REGION=ap-northeast-2" >> ~/.bashrc &&\
  echo "export DISPLAY=:0" >> ~/.bashrc &&\
  echo "export LIBGL_ALWAYS_INDIRECT=1" >> ~/.bashrc && \
  echo "export DRIVER=docker" >> ~/.bashrc && \
  echo "export CUCUMBER_PUBLISH_TOKEN=caa67d94-0eab-4593-90c7-6032772d86ec" >> ~/.bashrc

RUN git config --global pull.rebase false &&\
  git config --global push.autoSetupRemote true &&\
  git config --global branch.autoSetupMerge true

#Set up the app materials
RUN mkdir -p /home/colab/src/app
COPY containers/test_entrypoint.sh /home/colab/src/entrypoint.sh
WORKDIR /home/colab/src/app
RUN mise trust /home/colab/src/app/mise.toml && \
  mise settings add idiomatic_version_file_enable_tools ruby

ENV DRIVER=docker
ENV CUCUMBER_PUBLISH_TOKEN=caa67d94-0eab-4593-90c7-6032772d86ec

ENTRYPOINT  ["/home/colab/src/entrypoint.sh"]
CMD -r
