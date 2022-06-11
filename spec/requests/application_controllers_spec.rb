require "rails_helper"

RSpec.describe "ApplicationControllers", type: :request do
  describe "#render_404" do
    context "存在しないCategoryにアクセスする" do
      it "404エラーページを表示すること" do
        get "/categories/xxx"
        expect(response).to have_http_status(404)
        expect(response.body).to include "404 Not Found"
      end
    end

    context "存在しないArticleにアクセスする" do
      let!(:category) { create(:category) }

      it "404エラーページを表示すること" do
        get "/categories/#{category.slug}/articles/xxx"
        expect(response).to have_http_status(404)
        expect(response.body).to include "404 Not Found"
      end
    end

    context "存在しないパスにGETでアクセスする" do
      it "404エラーページを表示すること" do
        get "/undefined"
        expect(response).to have_http_status(404)
        expect(response.body).to include "404 Not Found"
      end
    end

    context "存在しないパスにPOSTでアクセスする" do
      it "404エラーページを表示すること" do
        post "/undefined"
        expect(response).to have_http_status(404)
        expect(response.body).to include "404 Not Found"
      end
    end

    context "存在しないパスにPATCHでアクセスする" do
      it "404エラーページを表示すること" do
        patch "/undefined"
        expect(response).to have_http_status(404)
        expect(response.body).to include "404 Not Found"
      end
    end

    context "存在しないパスにDELETEでアクセスする" do
      it "404エラーページを表示すること" do
        delete "/undefined"
        expect(response).to have_http_status(404)
        expect(response.body).to include "404 Not Found"
      end
    end
  end

  describe "#render_500" do
    let!(:category) { create(:category) }

    before do
      # モックでStandardErrorを発生させるようにする
      allow_any_instance_of(CategoriesController).to \
        receive(:show).and_raise(StandardError)
    end

    context "StandardErrorが発生する" do
      it "500エラーページを表示すること" do
        get category_path(category)
        expect(response).to have_http_status(500)
        expect(response.body).to include "500 Server Error"
      end
    end
  end

  describe "#not_published" do
    let!(:user) { create(:user) }
    let!(:article) { create(:article) }

    context "ログアウト時に非公開のArticleにアクセスする" do
      it "非公開ページを表示すること" do
        get category_article_path(article.category, article)
        expect(response).to have_http_status(404)
        expect(response.body).to include "非公開"
      end
    end

    context "ログイン時に非公開のArticleにアクセスする" do
      it "articlesのshowページを表示すること" do
        sign_in user
        get category_article_path(article.category, article)
        expect(response).to have_http_status(200)
        expect(response.body).to include article.title
      end
    end
  end
end
