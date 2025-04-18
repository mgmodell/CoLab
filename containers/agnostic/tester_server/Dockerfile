FROM ubuntu

RUN apt update && apt upgrade -y && \
  apt -y install \
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
  yarn

RUN apt -y install \
  libyaml-dev

RUN apt autoremove && \
    apt clean

RUN groupadd -r colab && \
  useradd --no-log-init -rm -d /home/colab -s /bin/bash -g colab colab


WORKDIR /home/colab

USER colab


SHELL ["/bin/bash", "-l", "-c"]

RUN echo -e "export S3_BUCKET_NAME=colab-dev" >> ~/.bashrc &&\
  echo -e "export AWS_ACCESS_KEY_ID=XXXXXXX" >> ~/.bashrc &&\
  echo -e "export AWS_SECRET_ACCESS_KEY=XXXXXXX" >> ~/.bashrc &&\
  echo -e "export AWS_REGION=ap-northeast-2" >> ~/.bashrc &&\
  echo -e "export DISPLAY=:0" >> ~/.bashrc &&\
  echo -e "export LIBGL_ALWAYS_INDIRECT=1" >> ~/.bashrc && \
  echo -e "export DRIVER=docker" >> ~/.bashrc && \
  echo -e "export CUCUMBER_PUBLISH_TOKEN=caa67d94-0eab-4593-90c7-6032772d86ec" >> ~/.bashrc

RUN git config --global pull.rebase false &&\
  git config --global push.autoSetupRemote true &&\
  git config --global branch.autoSetupMerge true

RUN curl -fsSL https://mise.jdx.dev/install.sh | sh
ENV PATH="/home/colab/.local/bin:$PATH"
RUN mkdir -p /home/colab/.local/share/mise && \
  echo 'eval "$(~/.local/bin/mise activate bash)"' >> /home/colab/.bashrc && \
  echo "export PATH=/home/colab/.local/bin:$PATH" >> ~/.bashrc

USER colab

#Set up the app materials
RUN mkdir -p /home/colab/src/app
COPY containers/test_entrypoint.sh /home/colab/src/entrypoint.sh
WORKDIR /home/colab/src/app

ENV DRIVER=docker
ENV CUCUMBER_PUBLISH_TOKEN=caa67d94-0eab-4593-90c7-6032772d86ec

ENTRYPOINT  ["/home/colab/src/entrypoint.sh"]
CMD -r
