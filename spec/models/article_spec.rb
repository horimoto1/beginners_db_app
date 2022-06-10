require "rails_helper"

RSpec.describe Article, type: :model do
  describe "バリデーション" do
    context "全ての属性が正しい場合" do
      it "バリデーションが通ること"
    end

    context "nameが不正の場合" do
      it "空ならばバリデーションが通らないこと"

      it "重複するならばバリデーションが通らないこと"
    end

    context "titleが不正の場合" do
      it "空ならばバリデーションが通らないこと"

      it "重複するならばバリデーションが通らないこと"
    end

    context "contentが不正の場合" do
      it "空ならばバリデーションが通らないこと"
    end

    context "article_orderが不正の場合" do
      it "空ならばバリデーションが通らないこと"
    end

    context "statusが不正の場合" do
      it "空ならばバリデーションが通らないこと"
    end

    context "category_idが不正の場合" do
      it "空ならばバリデーションが通らないこと"

      it "参照先が存在しなければバリデーションが通らないこと"
    end
  end

  describe "スコープ" do
    it "article_orderの昇順でソートされ、タイはidの昇順でソートされること"
    # 最小のarticle_orderを持つArticleを複数作成する
    # その中でidが最小のArticleがfirstならテストをパスする

    it "公開されているArticle一覧を取得すること"
  end

  describe "#should_generate_new_friendly_id?" do
    it "nameが更新されるとslugも自動で更新されること"
  end

  describe "#published?" do
    it "公開されている場合はtrueとなること"

    it "非公開の場合はfalseとなること"
  end

  describe "#previous_article" do
    context "同一の親Categoryに属すArticleが存在しない" do
      it "nilが返されること"
    end

    context "同一の親Categoryに属すArticleが存在する" do
      context "article_orderが小さいArticleが存在する" do
        it "前のArticleを取得できること"
      end

      context "article_orderが小さいArticleが存在しない" do
        it "nilが返されること"
      end

      context "article_orderがタイだが、idが小さいArticleが存在する" do
        it "前のArticleを取得できること"
      end

      context "article_orderがタイだが、idが小さいArticleが存在しない" do
        it "nilが返されること"
      end
    end
  end

  describe "#next_article" do
    context "同一の親Categoryに属すArticleが存在しない" do
      it "nilが返されること"
    end

    context "同一の親Categoryに属すArticleが存在する" do
      context "article_orderが大さいArticleが存在する" do
        it "次のArticleを取得できること"
      end

      context "article_orderが大さいArticleが存在しない" do
        it "nilが返されること"
      end

      context "article_orderがタイだが、idが大さいArticleが存在する" do
        it "次のArticleを取得できること"
      end

      context "article_orderがタイだが、idが大さいArticleが存在しない" do
        it "nilが返されること"
      end
    end
  end
end
