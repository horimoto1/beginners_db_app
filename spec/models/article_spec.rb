require "rails_helper"

RSpec.describe Article, type: :model do
  describe "バリデーション" do
    let!(:category) { create(:category) }
    let!(:article) { build(:article, category_id: category.id) }

    context "全ての属性が正しい場合" do
      it "バリデーションが通ること" do
        expect(article).to be_valid
      end
    end

    context "nameが不正の場合" do
      context "空の場合" do
        it "バリデーションが通らないこと" do
          article.name = ""
          expect(article).not_to be_valid
        end
      end

      context "重複する場合" do
        it "バリデーションが通らないこと" do
          article.save
          duplicate_article = build(:article, name: article.name)
          expect(duplicate_article).not_to be_valid
        end
      end
    end

    context "titleが不正の場合" do
      context "空の場合" do
        it "バリデーションが通らないこと" do
          article.title = ""
          expect(article).not_to be_valid
        end
      end

      context "重複する場合" do
        it "バリデーションが通らないこと" do
          article.save
          duplicate_article = build(:article, title: article.title)
          expect(duplicate_article).not_to be_valid
        end
      end
    end

    context "contentが不正の場合" do
      context "空の場合" do
        it "バリデーションが通らないこと" do
          article.content = ""
          expect(article).not_to be_valid
        end
      end
    end

    context "article_orderが不正の場合" do
      context "空の場合" do
        it "バリデーションが通らないこと" do
          article.article_order = nil
          expect(article).not_to be_valid
        end
      end
    end

    context "statusが不正の場合" do
      context "空の場合" do
        it "バリデーションが通らないこと" do
          article.status = ""
          expect(article).not_to be_valid
        end
      end
    end

    context "category_idが不正の場合" do
      context "空の場合" do
        it "バリデーションが通らないこと" do
          article.category_id = nil
          expect(article).not_to be_valid
        end
      end

      context "参照先が存在しない場合" do
        it "バリデーションが通らないこと" do
          article.category_id = -1
          expect(article).not_to be_valid
        end
      end
    end
  end

  describe "スコープ" do
    describe "#sorted" do
      # 最小のarticle_orderを持つArticleを複数作成する
      let!(:article_order_3) { create(:article, article_order: 3) }
      let!(:article_order_2) { create(:article, article_order: 2) }
      let!(:articles_order_1) { create_list(:article, 3, article_order: 1) }

      it "article_orderとidが最小のArticleが先頭に来ること" do
        expect(Article.sorted.first).to eq articles_order_1.min_by { |article| article.id }
      end
    end

    describe "#published" do
      let!(:published_articles) { create_list(:article, 3, published: true) }
      let!(:private_articles) { create_list(:article, 3) }

      it "公開されているArticleが全て含まれること" do
        published_articles.each do |published_article|
          expect(Article.published).to include published_article
        end
      end

      it "公開されていないArticleが全て含まれないこと" do
        private_articles.each do |private_article|
          expect(Article.published).not_to include private_article
        end
      end
    end
  end

  describe "#should_generate_new_friendly_id?" do
    let!(:article) { create(:article) }

    it "nameが更新されるとslugも自動で更新されること" do
      new_article_name = "sample"
      article.update(name: new_article_name)
      expect(article.slug).to eq new_article_name.parameterize
    end
  end

  describe "#published?" do
    let!(:published_article) { create(:article, published: true) }
    let!(:private_article) { create(:article) }

    it "公開されている場合はtrueとなること" do
      expect(published_article.published?).to be_truthy
    end

    it "非公開の場合はfalseとなること" do
      expect(private_article.published?).to be_falsey
    end
  end

  describe "#previous_article" do
    let!(:categories) { create_list(:category, 3) }
    let!(:article) {
      create(:article, article_order: 2,
                       category_id: categories.first.id)
    }

    context "同一の親Categoryに属すArticleが存在しない" do
      it "nilが返されること" do
        expect(article.previous_article).to be_nil
      end
    end

    context "同一の親Categoryに属すArticleが存在する" do
      context "article_orderが小さいArticleが存在する" do
        let!(:article_lt) {
          create(:article, article_order: 1,
                           category_id: categories.first.id)
        }

        it "前のArticleを取得できること" do
          expect(article.previous_article).to eq article_lt
        end
      end

      context "article_orderが小さいArticleが存在しない" do
        let!(:article_gt) {
          create(:article, article_order: 3,
                           category_id: categories.first.id)
        }

        it "nilが返されること" do
          expect(article.previous_article).to be_nil
        end
      end

      context "article_orderがタイのArticleが存在する" do
        let!(:article_eq) {
          create(:article, article_order: 2,
                           category_id: categories.first.id)
        }

        context "idが小さいArticleが存在する" do
          it "前のArticleを取得できること" do
            expect(article_eq.previous_article).to eq article
          end
        end

        context "idが小さいArticleが存在しない" do
          it "nilが返されること" do
            expect(article.previous_article).to be_nil
          end
        end
      end
    end
  end

  describe "#next_article" do
    let!(:categories) { create_list(:category, 3) }
    let!(:article) {
      create(:article, article_order: 2,
                       category_id: categories.first.id)
    }

    context "同一の親Categoryに属すArticleが存在しない" do
      it "nilが返されること" do
        expect(article.next_article).to be_nil
      end
    end

    context "同一の親Categoryに属すArticleが存在する" do
      context "article_orderが大さいArticleが存在する" do
        let!(:article_gt) {
          create(:article, article_order: 3,
                           category_id: categories.first.id)
        }

        it "次のArticleを取得できること" do
          expect(article.next_article).to eq article_gt
        end
      end

      context "article_orderが大さいArticleが存在しない" do
        let!(:article_lt) {
          create(:article, article_order: 1,
                           category_id: categories.first.id)
        }

        it "nilが返されること" do
          expect(article.next_article).to be_nil
        end
      end

      context "article_orderがタイのArticleが存在する" do
        let!(:article_eq) {
          create(:article, article_order: 2,
                           category_id: categories.first.id)
        }

        context "idが大さいArticleが存在する" do
          it "次のArticleを取得できること" do
            expect(article.next_article).to eq article_eq
          end
        end

        context "idが大さいArticleが存在しない" do
          it "nilが返されること" do
            expect(article_eq.next_article).to be_nil
          end
        end
      end
    end
  end
end
