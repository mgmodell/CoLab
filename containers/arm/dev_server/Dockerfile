FROM arm64v8/ubuntu

ARG UID=1000
ARG GID=1000

RUN apt update && apt upgrade -y
RUN apt -y install \
  curl \
  imagemagick \
  libvips \
  make \
  ruby-build \
  vim \
  git \
  bash \
  libmysqlclient-dev \
  yarn 

RUN apt -y install \
  libyaml-dev

RUN apt autoremove && \
    apt clean

RUN groupadd -g $GID -r colab && \
  useradd -u $UID -g $GID --no-log-init -rm -d /home/colab -s /bin/bash -g colab colab


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

RUN git clone --depth 1 https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.9.0 &&\
    echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bashrc && \
    echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.profile && \
    echo -e 'bundler \n foreman' >> ~/.default-gems

RUN source ~/.bashrc && \
  asdf plugin add ruby && \
  asdf plugin add bundler && \
  asdf plugin add nodejs && \
  asdf plugin add yarn

USER root

RUN mkdir /home/colab/.asdf/shims && \
  chown colab:colab /home/colab/.asdf/shims && \
  mkdir /home/colab/.asdf/installs && \
  chown colab:colab /home/colab/.asdf/installs

USER colab

#Set up the app materials
RUN mkdir -p /home/colab/src/app
COPY containers/dev_entrypoint.sh /home/colab/src/entrypoint.sh
WORKDIR /home/colab/src/app

ENV DRIVER docker
ENV COLAB_DB=db
ENV COLAB_DB_PORT=3306
ENV CUCUMBER_PUBLISH_TOKEN caa67d94-0eab-4593-90c7-6032772d86ec

ENTRYPOINT  ["/home/colab/src/entrypoint.sh"]
CMD -r
