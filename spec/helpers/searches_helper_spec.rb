require "rails_helper"

RSpec.describe SearchesHelper, type: :helper do
  let!(:text) { "テスト記事テスト1\nテスト2\nテスト3\n" }

  describe "#extract_substring" do
    context "入力文字列にキーワードが含まれる場合" do
      context "キーワードが1つの場合" do
        it "出力文字列に<b>タグで囲ったキーワードが含まれること" do
          keywords = ["テスト"]

          expect(extract_substring(text, keywords)).to \
            include "<b>#{keywords.first}</b>"
        end
      end

      context "キーワードが複数ある場合" do
        it "出力文字列に<b>タグで囲った1個目のキーワードが含まれること" do
          keywords = ["テスト1", "テスト2"]

          expect(extract_substring(text, keywords)).to \
            include "<b>#{keywords.first}</b>"
        end

        it "出力文字列に<b>タグで囲った2個目のキーワードが含まれること" do
          keywords = ["テスト1", "テスト2"]

          expect(extract_substring(text, keywords)).to \
            include "<b>#{keywords.second}</b>"
        end
      end

      context "最初の文にキーワードが含まれない場合" do
        it "出力文字列はキーワードを含む文から始まること" do
          keywords = ["テスト2"]

          expect(extract_substring(text, keywords)).to \
            match(%r{^<b>#{keywords.first}</b>})
        end
      end
    end

    context "入力文字列にキーワードが含まれない場合" do
      it "出力文字列に<b>タグで囲ったキーワードが含まれないこと" do
        keywords = ["サンプル"]

        expect(extract_substring(text, keywords)).not_to \
          include "<b>#{keywords.first}</b>"
      end

      it "出力文字列は最初の文から始まること" do
        keywords = ["サンプル"]

        expect(extract_substring(text, keywords)).to \
          match(/^テスト記事/)
      end
    end

    context "入力文字列が100文字より長い場合" do
      it "出力文字列は<b>タグを除き100文字に切り捨てられること" do
        long_text = "a" * 500
        keywords = ["a"]

        expect(strip_tags(extract_substring(long_text, keywords)).length).to eq 100
      end
    end
  end
end
