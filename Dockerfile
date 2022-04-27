FROM arm64v8/ubuntu

RUN apt update && apt upgrade
RUN apt -y install \
  curl \
  imagemagick \
  libvips \
  make \
  ruby-dev \
  git \
  bash \
  libmysqlclient-dev \
  yarn 

SHELL ["/bin/bash", "-l", "-c"]

# COPY containers/asdf-install-toolset /usr/local/bin
RUN echo -e "export S3_BUCKET_NAME=colab-dev" >> ~/.bashrc &&\
  echo -e "export AWS_ACCESS_KEY_ID=XXXXXXX" >> ~/.bashrc &&\
  echo -e "export AWS_SECRET_ACCESS_KEY=XXXXXXX" >> ~/.bashrc &&\
  echo -e "export AWS_REGION=ap-northeast-2" >> ~/.bashrc &&\
  echo -e "export DISPLAY=:0" >> ~/.bashrc &&\
  echo -e "export LIBGL_ALWAYS_INDIRECT=1" >> ~/.bashrc

RUN git clone --depth 1 https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.9.0
RUN echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bashrc && \
  echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.profile
RUN source ~/.bashrc && \
  asdf plugin add ruby && \
  asdf plugin add nodejs && \
  asdf plugin add yarn

RUN mkdir /usr/src/app



#RUN gem install bundler \
#  bundle install \
#  yarn install

WORKDIR /usr/src/app

CMD /bin/bash
