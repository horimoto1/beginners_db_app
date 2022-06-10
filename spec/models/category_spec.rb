require "rails_helper"

RSpec.describe Category, type: :model do
  describe "バリデーション" do
    context "全ての属性が正しい場合" do
      it "バリデーションが通ること"

      it "parent_category_idがnilでもバリデーションが通ること"
    end

    context "nameが不正の場合" do
      it "空ならばバリデーションが通らないこと"

      it "重複するならばバリデーションが通らないこと"
    end

    context "titleが不正の場合" do
      it "空ならばバリデーションが通らないこと"

      it "重複するならばバリデーションが通らないこと"
    end

    context "category_orderが不正の場合" do
      it "空ならばバリデーションが通らないこと"
    end

    context "parent_category_idが不正の場合" do
      it "参照先が存在しなければバリデーションが通らないこと"
    end
  end

  describe "スコープ" do
    it "category_orderの昇順でソートされ、タイはidの昇順でソートされること"
    # 最小のcategory_orderを持つCategoryを複数作成する
    # その中でidが最小のCategoryがfirstならテストをパスする

    it "ルートCategory一覧を取得すること"
  end

  describe "#should_generate_new_friendly_id?" do
    it "nameが更新されるとslugも自動で更新されること"
  end

  describe "#previous_category" do
    context "同一の親Categoryに属すCategoryが存在しない" do
      it "nilが返されること"
    end

    context "同一の親Categoryに属すCategoryが存在する" do
      context "category_orderが小さいCategoryが存在する" do
        it "前のCategoryを取得できること"
      end

      context "category_orderが小さいCategoryが存在しない" do
        it "nilが返されること"
      end

      context "category_orderがタイだが、idが小さいCategoryが存在する" do
        it "前のCategoryを取得できること"
      end

      context "category_orderがタイだが、idが小さいCategoryが存在しない" do
        it "nilが返されること"
      end
    end
  end

  describe "#next_category" do
    context "同一の親Categoryに属すCategoryが存在しない" do
      it "nilが返されること"
    end

    context "同一の親Categoryに属すCategoryが存在する" do
      context "category_orderが大きいCategoryが存在する" do
        it "次のCategoryを取得できること"
      end

      context "category_orderが大きいCategoryが存在しない" do
        it "nilが返されること"
      end

      context "category_orderがタイだが、idが大きいCategoryが存在する" do
        it "次のCategoryを取得できること"
      end

      context "category_orderがタイだが、idが大きいCategoryが存在しない" do
        it "nilが返されること"
      end
    end
  end

  describe "#breadcrumb_list" do
    it "ルートCategoryまで祖先Categoryを辿ったツリーを取得できること"
  end

  describe "associate" do
    it "削除時に子Categoryが削除されること"

    it "削除時に関連するArticleが削除されること"
  end
end
