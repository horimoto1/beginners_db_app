require "rails_helper"

RSpec.describe "ApplicationControllers", type: :request do
  describe "#not_found" do
    shared_examples "404エラーページ" do
      it "404エラーページを表示すること" do
        expect(response).to have_http_status(:not_found)
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

    context "ログアウト時" do
      context "非公開記事のみのカテゴリーにアクセスする" do
        let!(:category) { create(:category) }

        before do
          create(:article,
                 category_id: category.id)

          get category_path(category)
        end

        it_behaves_like "404エラーページ"
      end

      context "記事が1つも無いカテゴリーにアクセスする" do
        let!(:category) { create(:category) }

        before do
          get category_path(category)
        end

        it_behaves_like "404エラーページ"
      end
    end

    context "ログイン時" do
      let!(:user) { create(:user) }
      let!(:category) { create(:category) }

      context "非公開記事のみのカテゴリーにアクセスする" do
        before do
          create(:article,
                 category_id: category.id)

          sign_in user
          get category_path(category)
        end

        it "categoriesのshowページを表示すること" do
          expect(response).to have_http_status(:ok)
        end
      end

      context "記事が1つも無いカテゴリーにアクセスする" do
        let!(:category) { create(:category) }

        before do
          sign_in user
          get category_path(category)
        end

        it "categoriesのshowページを表示すること" do
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end

  describe "#server_error" do
    let!(:category) { create(:category) }

    before do
      create(:article,
             category_id: category.id,
             published: true)

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
      end
    end
  end

  describe "#access_denied" do
    context "ユーザに管理者権限が無い場合" do
      let!(:visiter) { create(:user, admin: false) }

      before do
        sign_in visiter
      end

      describe "カテゴリーの作成" do
        let!(:category) { attributes_for(:category) }

        it "作成に失敗すること" do
          expect { post categories_path, params: { category: category } }.not_to \
            change { Category.count }
          expect(flash).to be_any
          expect(response).to redirect_to(root_path)
        end
      end

      describe "カテゴリーの更新" do
        let!(:category) { create(:category) }

        it "更新に失敗すること" do
          expect {
            patch category_path(category), params: { category: { name: "sample" } }
          }.not_to change { category.reload.name }
          expect(flash).to be_any
          expect(response).to redirect_to(root_path)
        end
      end

      describe "カテゴリーの削除" do
        let!(:category) { create(:category) }

        it "削除に失敗すること" do
          expect { delete category_path(category) }.not_to \
            change { Category.count }
          expect(flash).to be_any
          expect(response).to redirect_to(root_path)
        end
      end

      describe "記事の投稿" do
        let!(:category) { create(:category) }
        let!(:article) { attributes_for(:article, category_id: category.id) }

        it "作成に失敗すること" do
          expect {
            post category_articles_path(category),
                 params: { article: article }
          }.not_to change { Article.count }
          expect(flash).to be_any
          expect(response).to redirect_to(root_path)
        end
      end

      describe "記事の更新" do
        let!(:article) { create(:article) }

        it "更新に失敗すること" do
          expect {
            patch category_article_path(article.category, article),
                  params: { article: { name: "sample" } }
          }.not_to change { article.reload.name }
          expect(flash).to be_any
          expect(response).to redirect_to(root_path)
        end
      end

      describe "記事の削除" do
        let!(:article) { create(:article) }

        it "削除に失敗すること" do
          expect { delete category_article_path(article.category, article) }.not_to \
            change { Article.count }
          expect(flash).to be_any
          expect(response).to redirect_to(root_path)
        end
      end

      describe "画像の投稿" do
        let!(:image) {
          Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/kitten.jpg"),
                                       "image/jpg")
        }

        it "作成に失敗すること" do
          expect { post attachments_path, params: { image: image } }.not_to \
            change { Attachment.count }
          expect(flash).to be_any
          expect(response).to redirect_to(root_path)
        end
      end

      describe "画像の削除" do
        let!(:attachment) { create(:attachment) }

        it "削除に失敗すること" do
          expect { delete attachment_path(attachment) }.not_to \
            change { Attachment.count }
          expect(flash).to be_any
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end
end
