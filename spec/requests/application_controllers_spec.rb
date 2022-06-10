require "rails_helper"

RSpec.describe "ApplicationControllers", type: :request do
  describe "#render_404" do
    context "存在しないCategoryにアクセスする" do
      it "404エラーページを表示すること"
    end

    context "存在しないArticleにアクセスする" do
      it "404エラーページを表示すること"
    end

    context "存在しないパスにアクセスする" do
      it "404エラーページを表示すること"
    end
  end

  describe "#render_500" do
    context "StandardErrorが発生する" do
      # モックを使用して例外をraiseする
      it "500エラーページを表示すること"
    end
  end

  describe "#not_published" do
    context "ログアウト時に非公開のArticleにアクセスする" do
      it "非公開ページを表示する"
    end

    context "ログイン時に非公開のArticleにアクセスする" do
      it "articlesのshowページを表示する"
    end
  end
end
