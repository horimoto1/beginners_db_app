# == Schema Information
#
# Table name: attachments
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Attachment < ApplicationRecord
  # Active Storage
  has_one_attached :image

  validates :image, content_type: { in: ["image/jpeg", "image/png",
                                         "image/gif", "image/svg+xml"],
                                    message: "のcontent-typeが無効です。" },
                    size: { less_than: 5.megabytes,
                            message: "のファイルサイズは5MB未満にしてください。" }
end
