require "rails_helper"

RSpec.describe "AttachmentsControllers", type: :request do
  describe "POST /attachments to #create" do
    let!(:user) { create(:user) }
    let!(:image) {
      Rack::Test::UploadedFile.new(File.join(Rails.root, "spec/fixtures/kitten.jpg"),
                                   "image/jpg")
    }
    let(:json) { JSON.parse(response.body) }

    context "ログアウト時" do
      it "作成に失敗すること" do
        expect { post attachments_path, params: { image: image } }.not_to \
          change { Attachment.count }
        expect(flash).to be_any
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン時" do
      it "作成に成功すること" do
        sign_in user
        expect { post attachments_path, params: { image: image } }.to \
          change { Attachment.count }.by(1)
        expect(json["filename"]).to eq URI.parse(url_for(Attachment.last.image)).path
      end
    end
  end

  describe "DELETE /attachments/:id to #destroy" do
    let!(:user) { create(:user) }
    let!(:attachment) { create(:attachment) }
    let(:json) { JSON.parse(response.body) }

    context "ログアウト時" do
      it "削除に失敗すること" do
        expect { delete attachment_path(attachment) }.not_to \
          change { Attachment.count }
        expect(flash).to be_any
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン時" do
      it "削除に成功すること" do
        sign_in user
        expect { delete attachment_path(attachment) }.to \
          change { Attachment.count }.by(-1)
        expect(json["message"]).to eq "画像を削除しました"
      end
    end
  end
end
