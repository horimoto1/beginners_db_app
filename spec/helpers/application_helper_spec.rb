require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#full_title" do
    let!(:base_title) { "DB入門" }

    context "引数無しで呼び出された場合" do
      it "base_titleを返すこと" do
        expect(full_title).to eq base_title
      end
    end

    context "引数有りで呼び出された場合" do
      it "引数 | base_titleを返すこと" do
        title = "sample"
        expect(full_title(title)).to eq "#{title} | #{base_title}"
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
end
