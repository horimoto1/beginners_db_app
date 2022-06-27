if @attachment.errors.empty?
  json.filename url_for(@attachment.image)
else
  json.filename '/assets/no_image'
  json.errors do
    json.array! @attachment.errors.full_messages
  end
end
