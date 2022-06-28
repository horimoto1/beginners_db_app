require "rails_helper"

RSpec.describe "DeviseSessionsControllers", type: :request do
  describe "GET /login to #new" do
    let!(:base_title) { "BeginnersDB" }

    context "ログアウト時" do
      before do
        get new_user_session_path
      end

      it "取得に成功すること" do
        expect(response).to have_http_status(:ok)
      end

      it "タイトルが正しいこと" do
        expect(response.body).to include "ログイン | #{base_title}"
      end
    end

    context "ログイン時" do
      let!(:user) { create(:user) }

      it "取得に失敗すること" do
        sign_in user
        get new_user_session_path
        expect(flash).to be_any
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "POST /login to #create" do
    let!(:user) { create(:user) }
    let!(:login_form) {
      { email: user.email, password: user.password,
        remember_me: 0 }
    }

    context "ログアウト時" do
      it "ログインに成功すること" do
        post user_session_path, params: { user: login_form }
        expect(flash).to be_any
        expect(response).to redirect_to(root_path)
        expect(controller.user_signed_in?).to be true
        expect(controller.current_user.email).to eq user.email
      end
    end

    context "ログイン時" do
      it "ログイン状態のままであること" do
        sign_in user
        post user_session_path, params: { user: login_form }
        expect(flash).to be_any
        expect(response).to redirect_to(root_path)
        expect(controller.user_signed_in?).to be true
        expect(controller.current_user.email).to eq user.email
      end
    end
  end

  describe "DELETE /logout to #destroy" do
    context "ログアウト時" do
      it "ログアウト状態のままであること" do
        delete destroy_user_session_path
        expect(flash).to be_any
        expect(response).to redirect_to(root_path)
        expect(controller.user_signed_in?).to be false
      end
    end

    context "ログイン時" do
      let!(:user) { create(:user) }

      it "ログアウトに成功すること" do
        sign_in user
        delete destroy_user_session_path
        expect(flash).to be_any
        expect(response).to redirect_to(root_path)
        expect(controller.user_signed_in?).to be false
      end
    end
  end
end
