FROM ubuntu

RUN apt update && apt upgrade -y && \
  apt -y install --fix-missing \
  curl \
  imagemagick \
  libvips \
  make \
  ruby-build \
  vim \
  git \
  autoconf \
  gettext \
  bash \
  libmysqlclient-dev \
  libyaml-dev \
  libsecret-1-dev \
  zsh

RUN apt autoremove && \
    apt clean

RUN groupadd -r colab && \
  useradd --no-log-init -rm -d /home/colab -s /bin/zsh -g colab colab



WORKDIR /home/colab

USER colab
RUN curl -fsSL https://mise.jdx.dev/install.sh | sh
ENV PATH="/home/colab/.local/bin:$PATH"
RUN mkdir -p /home/colab/.local/share/mise && \
  echo 'eval "$(~/.local/bin/mise activate zsh)"' >> /home/colab/.zshrc && \
  echo "export PATH=/home/colab/.local/bin:$PATH" >> ~/.zshrc && \
  echo "bundler \n foreman \n rubocop" >> ~/.default-gems && \
  mise install ruby yarn nodejs


SHELL ["/bin/bash", "-l", "-c"]

RUN echo -e "export S3_BUCKET_NAME=colab-dev" >> ~/.bashrc &&\
  echo -e "export AWS_ACCESS_KEY_ID=XXXXXXX" >> ~/.bashrc &&\
  echo -e "export AWS_SECRET_ACCESS_KEY=XXXXXXX" >> ~/.bashrc &&\
  echo -e "export AWS_REGION=ap-northeast-2" >> ~/.bashrc &&\
  echo -e "export DISPLAY=:0" >> ~/.bashrc &&\
  echo -e "export LIBGL_ALWAYS_INDIRECT=1" >> ~/.bashrc && \
  echo -e "export DRIVER=docker" >> ~/.bashrc && \
  echo -e "export CUCUMBER_PUBLISH_TOKEN=b7e96979-5fe5-43a0-9eae-42cffb5e8c13"


USER colab

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

#Set up the app materials
RUN sed -i 's/(git)/(\ngit\nmise\nbundler\nrails\nyarn\nrake\n)/g' ~/.zshrc
RUN mkdir -p /home/colab/src/app
COPY containers/dev_entrypoint.sh /home/colab/src/entrypoint.sh
WORKDIR /home/colab/src/app

ENV DRIVER=docker
ENV COLAB_DB=db
ENV COLAB_DB_PORT=3306
ENV CUCUMBER_PUBLISH_TOKEN=b7e96979-5fe5-43a0-9eae-42cffb5e8c13


# ENTRYPOINT  ["/home/colab/src/entrypoint.sh"]
# CMD -r
