if @attachment.errors.empty?
  json.filename url_for(@attachment.image)
else
  json.filename "画像のアップロードに失敗しました"
  json.errors do
    json.array! @attachment.errors.full_messages
  end
end
