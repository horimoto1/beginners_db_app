require "rails_helper"

RSpec.describe "ArticlesControllers", type: :request do
  describe "GET /categories/:category_id/articles/:id to #show" do
    let!(:base_title) { "BeginnersDB" }
    let!(:article) { create(:article, published: true) }

    before do
      get category_article_path(article.category, article)
    end

    it "取得に成功すること" do
      expect(response).to have_http_status(200)
    end

    it "タイトルが正しいこと" do
      expect(response.body).to include "#{article.title} | #{base_title}"
    end
  end

  describe "GET /categories/:category_id/articles/new to #new" do
    let!(:user) { create(:user) }
    let!(:category) { create(:category) }

    context "ログアウト時" do
      it "取得に失敗すること" do
        get new_category_article_path(category)
        expect(flash).to be_any
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン時" do
      it "取得に成功すること" do
        sign_in user
        get new_category_article_path(category)
        expect(response).to have_http_status(200)
      end
    end
  end

  describe "POST /categories/:category_id/articles to #create" do
    let!(:user) { create(:user) }
    let!(:category) { create(:category) }
    let!(:article) { attributes_for(:article, category_id: category.id) }

    context "ログアウト時" do
      it "作成に失敗すること" do
        expect {
          post category_articles_path(category),
               params: { article: article }
        }.not_to change { Article.count }
        expect(flash).to be_any
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン時" do
      it "作成に成功すること" do
        sign_in user
        expect {
          post category_articles_path(category),
               params: { article: article }
        }.to change { Article.count }.by(1)
        expect(flash).to be_any
        expect(response).to redirect_to(
          category_article_path(category, Article.last)
        )
      end
    end
  end

  describe "GET /categories/:category_id/articles/:id/edit to #edit" do
    let!(:user) { create(:user) }
    let!(:article) { create(:article) }

    context "ログアウト時" do
      it "取得に失敗すること" do
        get edit_category_article_path(article.category, article)
        expect(flash).to be_any
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン時" do
      it "取得に成功すること" do
        sign_in user
        get edit_category_article_path(article.category, article)
        expect(response).to have_http_status(200)
      end
    end
  end

  describe "PATCH /categories/:category_id/articles/:id to #update" do
    let!(:user) { create(:user) }
    let!(:article) { create(:article) }

    context "ログアウト時" do
      it "更新に失敗すること" do
        expect {
          patch category_article_path(article.category, article),
                params: { article: { name: "sample" } }
        }.not_to change { article.reload.name }
        expect(flash).to be_any
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン時" do
      it "更新に成功すること" do
        sign_in user
        expect {
          patch category_article_path(article.category, article),
                params: { article: { name: "sample" } }
        }.to change { article.reload.name }.to("sample")
        expect(flash).to be_any
        expect(response).to redirect_to(
          category_article_path(article.category, article)
        )
      end
    end
  end

  describe "DELETE /categories/:category_id/articles/:id to #destroy" do
    let!(:user) { create(:user) }
    let!(:article) { create(:article) }

    context "ログアウト時" do
      it "削除に失敗すること" do
        expect { delete category_article_path(article.category, article) }.not_to \
          change { Article.count }
        expect(flash).to be_any
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン時" do
      it "削除に成功すること" do
        sign_in user
        expect { delete category_article_path(article.category, article) }.to \
          change { Article.count }.by(-1)
        expect(flash).to be_any
        expect(response).to redirect_to(category_path(article.category))
      end
    end
  end
end
