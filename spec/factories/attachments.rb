# == Schema Information
#
# Table name: attachments
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :attachment do
    transient do
      image { "kitten.jpg" }
      content_type { "image/jpeg" }
    end

    after(:build) do |attachment, evaluator|
      if evaluator.image.present? && evaluator.content_type.present?
        attachment.image.attach(io: File.open("spec/fixtures/#{evaluator.image}"),
                                filename: evaluator.image,
                                content_type: evaluator.content_type)
      end
    end
  end
end
