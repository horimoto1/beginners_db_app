# ベースイメージ
FROM nginx:stable

# タイムゾーンの設定
RUN apt-get update -qq && \
  apt-get install -y \
  tzdata
ENV TZ=Asia/Tokyo

# パッケージのインストール
RUN apt-get update -qq && \
  apt-get install -y \
  certbot \
  python3-certbot-nginx

# デフォルトの設定ファイルを削除する
RUN rm -f /etc/nginx/conf.d/default.conf

# 設定ファイルをコピー
COPY ./docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./docker/nginx/conf.d/beginners_db_app.conf /etc/nginx/conf.d/beginners_db_app.conf

# ポートを解放する
EXPOSE 80 443

# nginxをフォアグラウンドで起動する
CMD /usr/sbin/nginx -g 'daemon off;'
