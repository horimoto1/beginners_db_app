class Attachment < ApplicationRecord
  # Active Storage
  has_one_attached :image

  validates :image, content_type: { in: ["image/jpeg", "image/png", "image/jpg",
                                         "image/gif"],
                                    message: "must be a valid image format" },
                    size: { less_than: 5.megabytes,
                            message: "should be less than 5MB" }
end
