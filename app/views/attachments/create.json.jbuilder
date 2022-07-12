if @attachment.errors.empty?
  json.orig_file_name @attachment.image.filename
  json.filename url_for(@attachment.image)
else
  json.orig_file_name ""
  json.filename "http://"
  json.errors do
    json.array! @attachment.errors.full_messages
  end
end
