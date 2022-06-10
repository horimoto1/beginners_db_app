require "rails_helper"

RSpec.describe MarkdownHelper, type: :helper do
  describe "#markdown" do
    it "改行が<br>に変換されること"

    it "単語内の_が強調として解析されないこと"
    # スネークケースなど

    it "テーブルを解析すること"
    # divタグで囲って出力する

    it "複数行のコードブロックを解析すること"

    it "<>で囲ってないリンクを解析すること"

    it "通常記法のコードブロックを解析しないこと"
    # 通常記法では、各行の先頭にある4つのスペースを持つテキストをコードブロックに変換する

    it "打ち消し線を解析すること"

    it "前後の空行がないブロックレベルのHTML要素を出力すること"
    # 通常記法では、ブロックレベルのHTML要素を埋め込むためには前後に空行を必要とする

    it "#の後に空白が無ければ見出しと認めないこと"

    it "上付き文字を解析すること"

    it "強調を解析すること"

    it "ハイライトを解析すること"

    it "引用符を解析すること"

    it "注釈と脚注リンクを解析すること"

    context "コードブロックにシンタックスハイライトを適用すること" do
      it "sql"

      it "ruby"

      it "yaml"

      it "readme"
    end
  end

  describe "#toc" do
    it "hタグからインデントされた目次を生成すること"
  end

  describe "#plaintext" do
    it "プレーンテキストを抽出すること"
  end
end
