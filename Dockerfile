# ベースイメージ
FROM ubuntu:20.04

# タイムゾーンの設定
RUN apt-get update -qq && \
  apt-get install -y \
  tzdata
ENV TZ=Asia/Tokyo

# パッケージをインストール
RUN apt-get update -qq && \
  apt-get install -y \
  git \
  build-essential \
  libpq-dev \
  libssl-dev \
  zlib1g-dev \
  postgresql-client \
  imagemagick \
  vim \
  curl \
  wget \
  unzip

# google-chromeをインストール
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add && \
  echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | tee /etc/apt/sources.list.d/google-chrome.list && \
  apt-get update -qq && \
  apt-get install -y \
  google-chrome-stable \
  libnss3 \
  libgconf-2-4

# chromedriverをインストール
RUN wget -O LATEST_RELEASE_ "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$(google-chrome --version | cut -d ' ' -f 3 | sed -e 's/\.[0-9]*$//')" && \
  curl -sS -o /tmp/chromedriver_linux64.zip http://chromedriver.storage.googleapis.com/$(cat LATEST_RELEASE_)/chromedriver_linux64.zip && \
  rm -f LATEST_RELEASE_ && \
  unzip /tmp/chromedriver_linux64.zip && \
  mv chromedriver /usr/local/bin/

# Rubyをインストール
RUN git clone https://github.com/rbenv/ruby-build.git && \
  PREFIX=/usr/local ./ruby-build/install.sh && \
  rm -rf ruby-build && \
  ruby-build 2.7.6 /usr/local

# Node.jsとyarnをインストール
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
  apt-get update -qq && \
  apt-get install -y nodejs && \
  npm install -g yarn

# コンテナ内のワークディレクトリを指定
WORKDIR /srv/beginners_db_app

# 起動時のスクリプトをコピー
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Gemをインストール
COPY Gemfile /srv/beginners_db_app/Gemfile
COPY Gemfile.lock /srv/beginners_db_app/Gemfile.lock
RUN bundle install

# npmパッケージをインストール
COPY package.json /srv/beginners_db_app/package.json
COPY yarn.lock /srv/beginners_db_app/yarn.lock
RUN yarn install && \
  yarn global add eslint-cli

# ファイルをコピー
COPY . /srv/beginners_db_app

# railsを起動する
CMD rails s
