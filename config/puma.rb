# スレッド数
max_threads_count = ENV.fetch("RAILS_MAX_THREADS", 5)
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# 起動方法
rails_env = ENV.fetch("RAILS_ENV") { "development" }
if rails_env == "production"
  # UNIXドメインソケット通信
  bind "unix://#{Rails.root}/tmp/sockets/puma.sock"

  # デーモン化
  daemonize true
else
  # ポート番号
  port ENV.fetch("PORT", 3000)
end

# 実行環境
environment rails_env

# プロセスID
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# ワーカープロセス数
workers ENV.fetch("WEB_CONCURRENCY", 2)

# アプリを事前ロードしてワーカープロセスの起動時間を減らす
preload_app!

# rails restartコマンドでpumaを再起動できるようにするプラグイン
plugin :tmp_restart
