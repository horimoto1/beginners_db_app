require 'rails_helper'

RSpec.describe 'AttachmentsControllers', type: :request do
  let!(:user) { create(:user) }

  describe 'GET /attachments to #index' do
    let!(:base_title) { 'BeginnersDB' }

    context 'ログアウト時' do
      it '取得に失敗すること' do
        get attachments_path
        expect(flash).to be_any
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログイン時' do
      before do
        sign_in user
        get attachments_path
      end

      it '取得に成功すること' do
        expect(response).to have_http_status(:ok)
      end

      it 'タイトルが正しいこと' do
        expect(response.body).to include "画像一覧 | #{base_title}"
      end
    end
  end

  describe 'POST /attachments to #create' do
    let!(:image) {
      Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/kitten.jpg'),
                                   'image/jpg')
    }

    context 'ログアウト時' do
      it '作成に失敗すること' do
        expect { post attachments_path, params: { image: image } }.not_to \
          change { Attachment.count }
        expect(flash).to be_any
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログイン時' do
      it '作成に成功すること' do
        sign_in user
        expect { post attachments_path, params: { image: image } }.to \
          change { Attachment.count }.by(1)
        expect(JSON.parse(response.body)['filename']).to \
          eq URI.parse(url_for(Attachment.last.image)).path
      end
    end
  end

  describe 'DELETE /attachments/:id to #destroy' do
    let!(:attachment) { create(:attachment) }

    context 'ログアウト時' do
      it '削除に失敗すること' do
        expect { delete attachment_path(attachment) }.not_to \
          change { Attachment.count }
        expect(flash).to be_any
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログイン時' do
      it '削除に成功すること' do
        sign_in user
        expect { delete attachment_path(attachment) }.to \
          change { Attachment.count }.by(-1)
        expect(flash).to be_any
        expect(response).to redirect_to(attachments_path)
      end
    end
  end
end
