require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#full_title" do
    context "引数無しの場合" do
      it "BeginnersDBを返す"
    end

    context "引数有りの場合" do
      it "引数 | BeginnersDBを返す"
    end
  end

  describe "#object_path" do
    context "引数がCategoryの場合" do
      it "categories/:idを返す"
    end

    context "引数がArticleの場合" do
      it "categories/:category_id/Articles/:article_idを返す"
    end

    context "引数がそれ以外の場合" do
      it "nilを返す"
    end
  end

  describe "#login_filter" do
    context "ログイン中" do
      context "引数がActiveRecord::RelationでmodelがArticleの場合" do
        it "公開していないArticleも取得する"
      end

      context "引数がActiveRecord::RelationだがmodelがArticleではない場合" do
        it "引数をそのまま返す"
      end

      context "引数がArticleの場合" do
        it "公開している場合はそのまま返す"

        it "公開していない場合もそのまま返す"
      end

      context "引数がそれ以外の場合" do
        it "引数をそのまま返す"
      end
    end

    context "ログアウト中" do
      context "引数がActiveRecord::RelationでmodelがArticleの場合" do
        it "未公開のArticleが含まれない"
      end

      context "引数がActiveRecord::RelationだがmodelがArticleではない場合" do
        it "引数をそのまま返す"
      end

      context "引数がArticleの場合" do
        it "公開している場合はそのまま返す"

        it "未公開の場合はnilを返す"
      end

      context "引数がそれ以外の場合" do
        it "引数をそのまま返す"
      end
    end
  end
end
