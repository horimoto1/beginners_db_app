namespace :storage do
  desc "アタッチされていないファイルを削除する"
  task clean: :environment do
    ActiveStorage::Blob.unattached.find_each(&:purge)
    puts "Clean storage"
  end
end
