# == Schema Information
#
# Table name: attachments
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "rails_helper"

RSpec.describe Attachment, type: :model do
  describe "バリデーション" do
    context "全ての属性が正しい場合" do
      context "content_typeがimage/jpegの場合" do
        let!(:attachment) { build(:attachment) }

        it "バリデーションが通ること" do
          expect(attachment).to be_valid
        end
      end

      context "content_typeがimage/pngの場合" do
        let!(:attachment) {
          build(:attachment, image: "480x320.png",
                             content_type: "image/png")
        }

        it "バリデーションが通ること" do
          expect(attachment).to be_valid
        end
      end

      context "content_typeがimage/gifの場合" do
        let!(:attachment) {
          build(:attachment, image: "480x320.gif",
                             content_type: "image/gif")
        }

        it "バリデーションが通ること" do
          expect(attachment).to be_valid
        end
      end

      context "content_typeがimage/svg+xmlの場合" do
        let!(:attachment) {
          build(:attachment, image: "rails.svg",
                             content_type: "image/svg+xml")
        }

        it "バリデーションが通ること" do
          expect(attachment).to be_valid
        end
      end

      context "file_sizeが4MBの場合" do
        let!(:attachment) {
          build(:attachment, image: "4MB.png",
                             content_type: "image/png")
        }

        it "バリデーションが通ること" do
          expect(attachment).to be_valid
        end
      end
    end

    context "imageが不正の場合" do
      context "content_typeがimage/webpの場合" do
        let!(:attachment) {
          build(:attachment, image: "480x320.webp",
                             content_type: "image/webp")
        }

        it "バリデーションが通らないこと" do
          expect(attachment).not_to be_valid
        end
      end

      context "file_sizeが5MBの場合" do
        let!(:attachment) {
          build(:attachment, image: "5MB.png",
                             content_type: "image/png")
        }

        it "バリデーションが通らないこと" do
          expect(attachment).not_to be_valid
        end
      end
    end
  end
end
