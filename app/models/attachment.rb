class Attachment < ApplicationRecord
  # Active Storage
  has_one_attached :image

  validates :image, content_type: { in: ["image/jpeg", "image/png", "image/jpg",
                                         "image/gif"],
                                    message: "のcontent-typeが無効です。" },
                    size: { less_than: 5.megabytes,
                            message: "のファイルサイズは5MB未満にしてください。" }
end
