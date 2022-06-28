require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#full_title" do
    context "引数無しで呼び出された場合" do
      it "BeginnersDBを返すこと" do
        expect(full_title).to eq "BeginnersDB"
      end
    end

    context "引数有りで呼び出された場合" do
      it "引数 | BeginnersDBを返すこと" do
        title = "sample"
        expect(full_title(title)).to eq "#{title} | BeginnersDB"
      end
    end
  end

  describe "#object_path" do
    context "引数がCategoryの場合" do
      let!(:category) { create(:category) }

      it "Categoryのパスを返すこと" do
        expect(object_path(category)).to eq category_path(category)
      end
    end

    context "引数がArticleの場合" do
      let!(:article) { create(:article) }

      it "Articleのパスを返すこと" do
        expect(object_path(article)).to eq category_article_path(article.category, article)
      end
    end

    context "引数がそれ以外の場合" do
      it "nilを返すこと" do
        expect(object_path("sample")).to be_nil
      end
    end
  end

  describe "#login_filter" do
    let!(:published_articles) { create_list(:article, 3, published: true) }
    let!(:private_articles) { create_list(:article, 3) }

    context "ログアウト中" do
      before do
        # Rspec経由でuser_signed_in?が呼び出せなかったのでスタブ化する
        allow(helper).to receive(:user_signed_in?).and_return(false)
      end

      context "引数がActiveRecord::Relationの場合" do
        context "modelがArticleの場合" do
          let!(:articles) { Article.all }

          it "未公開のArticleが全て含まれないこと" do
            private_articles.each do |private_article|
              expect(helper.login_filter(articles)).not_to include private_article
            end
          end
        end

        context "modelがArticleではない場合" do
          let!(:categories) { Category.all }

          it "引数をそのまま返すこと" do
            expect(helper.login_filter(categories)).to eq categories
          end
        end
      end

      context "引数がArticleの場合" do
        context "公開している場合" do
          let!(:published_article) { published_articles.first }

          it "引数をそのまま返すこと" do
            expect(helper.login_filter(published_article)).to eq published_article
          end
        end

        context "公開していない場合" do
          let!(:private_article) { private_articles.first }

          it "nilを返すこと" do
            expect(helper.login_filter(private_article)).to be_nil
          end
        end
      end

      context "引数がそれ以外の場合" do
        it "引数をそのまま返すこと" do
          object = "sample"
          expect(helper.login_filter(object)).to be object
        end
      end
    end

    context "ログイン中" do
      let!(:user) { create(:user) }

      before do
        sign_in user
        # Rspec経由でuser_signed_in?が呼び出せなかったのでスタブ化する
        allow(helper).to receive(:user_signed_in?).and_return(true)
      end

      context "引数がActiveRecord::Relationの場合" do
        context "modelがArticleの場合" do
          let!(:articles) { Article.all }

          it "未公開のArticleも全て取得すること" do
            private_articles.each do |private_article|
              expect(helper.login_filter(articles)).to include private_article
            end
          end
        end

        context "modelがArticleではない場合" do
          let!(:categories) { Category.all }

          it "引数をそのまま返すこと" do
            expect(helper.login_filter(categories)).to eq categories
          end
        end
      end

      context "引数がArticleの場合" do
        context "公開している場合" do
          let!(:published_article) { published_articles.first }

          it "引数をそのまま返すこと" do
            expect(helper.login_filter(published_article)).to eq published_article
          end
        end

        context "公開していない場合" do
          let!(:private_article) { private_articles.first }

          it "引数をそのまま返すこと" do
            expect(helper.login_filter(private_article)).to eq private_article
          end
        end
      end

      context "引数がそれ以外の場合" do
        it "引数をそのまま返すこと" do
          object = "sample"
          expect(helper.login_filter(object)).to be object
        end
      end
    end
  end
end
