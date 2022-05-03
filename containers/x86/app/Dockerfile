FROM ubuntu

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

RUN apt autoremove && \
    apt clean

RUN groupadd -r colab && \
  useradd --no-log-init -rm -d /home/colab -s /bin/bash -g colab colab

USER colab


WORKDIR /home/colab
RUN mkdir .ssh/
COPY containers/id_rsa .ssh/

RUN mkdir -p /home/colab/src/app
WORKDIR /home/colab/src/app

SHELL ["/bin/bash", "-l", "-c"]

RUN echo -e "export S3_BUCKET_NAME=colab-dev" >> ~/.bashrc &&\
  echo -e "export AWS_ACCESS_KEY_ID=XXXXXXX" >> ~/.bashrc &&\
  echo -e "export AWS_SECRET_ACCESS_KEY=XXXXXXX" >> ~/.bashrc &&\
  echo -e "export AWS_REGION=ap-northeast-2" >> ~/.bashrc &&\
  echo -e "export DISPLAY=:0" >> ~/.bashrc &&\
  echo -e "export LIBGL_ALWAYS_INDIRECT=1" >> ~/.bashrc

RUN git clone --depth 1 https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.9.0 &&\
    echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bashrc && \
    echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.profile && \
     echo 'bundler' >> ~/.default-gems

RUN source ~/.bashrc && \
  asdf plugin add ruby && \
  asdf plugin add nodejs && \
  asdf plugin add yarn

USER root

RUN mkdir /home/colab/.asdf/installs && \
  chown colab:colab /home/colab/.asdf/installs

USER colab

CMD /bin/bash
