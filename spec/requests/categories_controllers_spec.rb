require "rails_helper"

RSpec.describe "CategoriesControllers", type: :request do
  describe "GET /categories/:id to #show" do
    let!(:category) { create(:category) }

    before do
      create(:article,
             category_id: category.id,
             published: true)

      get category_path(category)
    end

    it "取得に成功すること" do
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /categories/new to #new" do
    let!(:user) { create(:user) }

    context "ログアウト時" do
      it "取得に失敗すること" do
        get new_category_path
        expect(flash).to be_any
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン時" do
      before do
        sign_in user
        get new_category_path
      end

      it "取得に成功すること" do
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST /categories to #create" do
    let!(:user) { create(:user) }
    let!(:category) { attributes_for(:category) }

    context "ログアウト時" do
      it "作成に失敗すること" do
        expect { post categories_path, params: { category: category } }.not_to \
          change { Category.count }
        expect(flash).to be_any
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン時" do
      it "作成に成功すること" do
        sign_in user
        expect { post categories_path, params: { category: category } }.to \
          change { Category.count }.by(1)
        expect(flash).to be_any
        expect(response).to redirect_to(category_path(Category.last))
      end
    end
  end

  describe "GET /categories/:id/edit to #edit" do
    let!(:user) { create(:user) }
    let!(:category) { create(:category) }

    context "ログアウト時" do
      it "取得に失敗すること" do
        get edit_category_path(category)
        expect(flash).to be_any
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン時" do
      before do
        sign_in user
        get edit_category_path(category)
      end

      it "取得に成功すること" do
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "PATCH /categories/:id to #update" do
    let!(:user) { create(:user) }
    let!(:category) { create(:category) }

    context "ログアウト時" do
      it "更新に失敗すること" do
        expect {
          patch category_path(category), params: { category: { name: "sample" } }
        }.not_to change { category.reload.name }
        expect(flash).to be_any
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン時" do
      it "更新に成功すること" do
        sign_in user
        expect {
          patch category_path(category), params: { category: { name: "sample" } }
        }.to change { category.reload.name }.to("sample")
        expect(flash).to be_any
        expect(response).to redirect_to(category_path(category))
      end
    end
  end

  describe "DELETE /categories/:id to #destroy" do
    let!(:user) { create(:user) }
    let!(:category) { create(:category) }

    context "ログアウト時" do
      it "削除に失敗すること" do
        expect { delete category_path(category) }.not_to \
          change { Category.count }
        expect(flash).to be_any
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン時" do
      it "削除に成功すること" do
        sign_in user
        expect { delete category_path(category) }.to \
          change { Category.count }.by(-1)
        expect(flash).to be_any
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
