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
  curl

# Ruby v2.7.6をインストール
RUN git clone https://github.com/rbenv/ruby-build.git && \
  PREFIX=/usr/local ./ruby-build/install.sh && \
  rm -rf ruby-build && \
  ruby-build 2.7.6 /usr/local

# Node.js v18.xをインストール
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

# パッケージ管理ファイルをコピー
COPY Gemfile /srv/beginners_db_app/Gemfile
COPY Gemfile.lock /srv/beginners_db_app/Gemfile.lock
COPY package.json /srv/beginners_db_app/package.json
COPY yarn.lock /srv/beginners_db_app/yarn.lock

# パッケージをインストール
RUN bundle install
RUN yarn install

# ファイルをコピー
COPY . /srv/beginners_db_app

# railsを起動する
CMD rails s
