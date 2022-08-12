# == Schema Information
#
# Table name: articles
#
#  id            :bigint           not null, primary key
#  article_order :integer          not null
#  content       :text             not null
#  name          :string           not null
#  slug          :string           default(""), not null
#  status        :string           not null
#  summary       :text
#  title         :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  category_id   :bigint           not null
#
# Indexes
#
#  index_articles_on_category_id                    (category_id)
#  index_articles_on_category_id_and_article_order  (category_id,article_order)
#  index_articles_on_name                           (name) UNIQUE
#  index_articles_on_slug                           (slug) UNIQUE
#  index_articles_on_title                          (title) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (category_id => categories.id)
#
require "rails_helper"

RSpec.describe Article, type: :model do
  describe "バリデーション" do
    let!(:category) { create(:category) }
    let!(:article) { build(:article, category_id: category.id) }

    context "全ての属性が正しい場合" do
      context "imageが無い場合" do
        it "バリデーションが通ること" do
          expect(article).to be_valid
        end
      end

      context "imageがある場合" do
        let!(:article_with_image) {
          build(:article, category_id: category.id,
                          image: "kitten.jpg",
                          content_type: "image/jpeg")
        }

        it "バリデーションが通ること" do
          expect(article_with_image).to be_valid
        end
      end
    end

    context "imageが不正の場合" do
      context "content_typeがimage/webpの場合" do
        let!(:article_with_image) {
          build(:article, category_id: category.id,
                          image: "480x320.webp",
                          content_type: "image/webp")
        }

        it "バリデーションが通らないこと" do
          expect(article_with_image).not_to be_valid
        end
      end

      context "file_sizeが5MBの場合" do
        let!(:article_with_image) {
          build(:article, category_id: category.id,
                          image: "5MB.png",
                          content_type: "image/png")
        }

        it "バリデーションが通らないこと" do
          expect(article_with_image).not_to be_valid
        end
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
      let!(:articles_order_1) { create_list(:article, 3, article_order: 1) }

      before do
        create(:article, article_order: 3)
        create(:article, article_order: 2)
      end

      it "article_orderとidが最小のArticleが先頭に来ること" do
        expect(Article.sorted.first).to eq articles_order_1.min_by(&:id)
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
      expect(published_article.published?).to be true
    end

    it "非公開の場合はfalseとなること" do
      expect(private_article.published?).to be false
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
        before do
          create(:article, article_order: 3,
                           category_id: categories.first.id)
        end

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
        before do
          create(:article, article_order: 1,
                           category_id: categories.first.id)
        end

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
