FactoryBot.define do
  factory :attachment do
    transient do
      image { "kitten.jpg" }
      content_type { "image/jpeg" }
    end

    after(:build) do |attachment, evaluator|
      attachment.image.attach(io: File.open("spec/fixtures/#{evaluator.image}"),
                              filename: evaluator.image,
                              content_type: evaluator.content_type)
    end
  end
end
