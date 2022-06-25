require "rails_helper"
include MarkdownHelper

RSpec.describe SearchesHelper, type: :helper do
  let!(:article) { create(:article, published: true) }
  let(:text) { article.summary + plaintext(article.content) }

  describe "#extract_substring" do
    context "入力文字列にキーワードが含まれる場合" do
      context "キーワードが1つの場合" do
        it "出力文字列に太字化されたキーワードが含まれること" do
          keywords = ["テスト"]

          expect(extract_substring(text, keywords)).to \
            include "<b>#{keywords.first}</b>"
        end
      end

      context "キーワードが複数ある場合" do
        it "出力文字列に太字化された1個目のキーワードが含まれること" do
          keywords = ["テスト1", "テスト2"]

          expect(extract_substring(text, keywords)).to \
            include "<b>#{keywords.first}</b>"
        end

        it "出力文字列に太字化された2個目のキーワードが含まれること" do
          keywords = ["テスト1", "テスト2"]

          expect(extract_substring(text, keywords)).to \
            include "<b>#{keywords.second}</b>"
        end
      end
    end

    context "入力文字列にキーワードが含まれない場合" do
      it "出力文字列に太字化されたキーワードが含まれないこと" do
        keywords = ["サンプル"]

        expect(extract_substring(text, keywords)).not_to \
          include "<b>#{keywords.first}</b>"
      end
    end

    context "入力文字列が100文字より長い場合" do
      it "出力文字列は100文字になっていること" do
        long_text = "a" * 500
        keywords = ["b"]

        expect(extract_substring(long_text, keywords).length).to eq 100
      end
    end
  end
end
