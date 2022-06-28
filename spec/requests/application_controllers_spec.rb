require "rails_helper"

RSpec.describe "ApplicationControllers", type: :request do
  let!(:base_title) { "BeginnersDB" }

  describe "#not_found" do
    shared_examples "404エラーページ" do
      it "404エラーページを表示すること" do
        expect(response).to have_http_status(:not_found)
      end

      it "タイトルが正しいこと" do
        expect(response.body).to include "404 Not Found | #{base_title}"
      end
    end

    context "存在しないCategoryにアクセスする" do
      before do
        get "/categories/-1"
      end

      it_behaves_like "404エラーページ"
    end

    context "存在しないArticleにアクセスする" do
      let!(:category) { create(:category) }

      before do
        get "/categories/#{category.slug}/articles/-1"
      end

      it_behaves_like "404エラーページ"
    end

    context "存在しないパスにGETでアクセスする" do
      before do
        get "/undefined"
      end

      it_behaves_like "404エラーページ"
    end

    context "存在しないパスにPOSTでアクセスする" do
      before do
        post "/undefined"
      end

      it_behaves_like "404エラーページ"
    end

    context "存在しないパスにPATCHでアクセスする" do
      before do
        patch "/undefined"
      end

      it_behaves_like "404エラーページ"
    end

    context "存在しないパスにDELETEでアクセスする" do
      before do
        delete "/undefined"
      end

      it_behaves_like "404エラーページ"
    end
  end

  describe "#server_error" do
    let!(:category) { create(:category) }

    before do
      # モックでStandardErrorを発生させるようにする
      allow_any_instance_of(CategoriesController).to \
        receive(:show).and_raise(StandardError)
    end

    context "StandardErrorが発生する" do
      before do
        get category_path(category)
      end

      it "500エラーページを表示すること" do
        expect(response).to have_http_status(:internal_server_error)
      end

      it "タイトルが正しいこと" do
        expect(response.body).to include "500 Server Error | #{base_title}"
      end
    end
  end

  describe "#not_published" do
    let!(:user) { create(:user) }
    let!(:article) { create(:article) }

    context "ログアウト時" do
      context "非公開のArticleにアクセスする" do
        before do
          get category_article_path(article.category, article)
        end

        it "非公開ページを表示すること" do
          expect(response).to have_http_status(:not_found)
        end

        it "タイトルが正しいこと" do
          expect(response.body).to include "非公開 | #{base_title}"
        end
      end
    end

    context "ログイン時" do
      context "非公開のArticleにアクセスする" do
        before do
          sign_in user
          get category_article_path(article.category, article)
        end

        it "articlesのshowページを表示すること" do
          expect(response).to have_http_status(:ok)
        end

        it "タイトルが正しいこと" do
          expect(response.body).to include "#{article.title} | #{base_title}"
        end
      end
    end
  end
end
