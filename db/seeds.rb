FactoryBot.definition_file_paths = [Rails.root.join('spec/factories')]
FactoryBot.reload

table_names = %w[
  users
  categories
  articles
  attachments
]

table_names.each do |table_name|
  path = Rails.root.join("db/seeds/#{Rails.env}/#{table_name}.rb")
  if File.exist?(path)
    puts "Creating #{table_name}..."
    require path
  end
end
