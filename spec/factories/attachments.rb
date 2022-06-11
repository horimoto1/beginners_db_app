FactoryBot.define do
  factory :attachment do
    after(:build) do |attachment|
      attachment.image.attach(io: File.open("spec/fixtures/kitten.jpg"),
                              filename: "kitten.jpg", content_type: "image/jpg")
    end
  end
end
