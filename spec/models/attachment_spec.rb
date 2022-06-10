require "rails_helper"

RSpec.describe Attachment, type: :model do
  describe "バリデーション" do
    context "全ての属性が正しい場合" do
      it "content_typeがimage/jpegでもバリデーションが通ること"

      it "content_typeがimage/pngでもバリデーションが通ること"

      it "content_typeがimage/jpgでもバリデーションが通ること"

      it "content_typeがimage/gifでもバリデーションが通ること"

      it "sizeが4.9MBでもバリデーションが通ること"
    end

    context "imageが不正" do
      it "content_typeが未定義ならばバリデーションが通らないこと"

      it "sizeが5MBならばバリデーションが通らないこと"
    end
  end
end
