# SVG画像を添付ファイルではなくインラインで取得できるようにする
Rails.application.config.active_storage.content_types_to_serve_as_binary.delete("image/svg+xml")
Rails.application.config.active_storage.content_types_allowed_inline << "image/svg+xml"
