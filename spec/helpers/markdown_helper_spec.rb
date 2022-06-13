require "rails_helper"

RSpec.describe MarkdownHelper, type: :helper do
  describe "#markdown" do
    describe "option" do
      it "改行が<br>に変換されること" do
        text = <<~EOS
          aaa
          bbb
          ccc
        EOS

        expect(markdown(text)).to include "<br>"
      end

      it "単語内の_が解析されないこと" do
        text = "aaa_aaa_aaa"

        expect(markdown(text)).not_to include "<u>aaa</u>"
      end

      it "テーブルを解析すること" do
        text = <<~EOS
          | Column 1 | Column 2 | Column 3 |
          | -------- | -------- | -------- |
          | Text     | Text     | Text     |
        EOS

        expect(markdown(text)).to include %(<div class="table-wrapper"><table>)
      end

      it "複数行のコードブロックを解析すること" do
        text = <<~EOS
          ```sql:sample.sql
          SELECT *
           FROM table;
           WHERE id = id;
          ```
        EOS

        expect(markdown(text)).to include %(<div class="code">)
      end

      it "<>で囲ってないリンクを解析すること" do
        text = "[Google](https://www.google.com/)"

        expect(markdown(text)).to include %(<a href="https://www.google.com/">Google</a>)
      end

      # 適用されないため削除
      #   xit "通常記法のコードブロックを解析しないこと" do
      #     # 通常記法では、各行の先頭にある4つのスペースを持つテキストをコードブロックに変換する
      #     text = <<-EOS
      # SELECT *
      # FROM table;
      # WHERE id = id;
      #   EOS

      #     expect(markdown(text)).not_to include %(<div class="code">)
      #   end

      it "打ち消し線を解析すること" do
        text = "~~aaa~~"

        expect(markdown(text)).to include "<del>aaa</del>"
      end

      it "前後の空行がないブロックレベルのHTML要素を出力すること" do
        # 通常記法では、ブロックレベルのHTML要素を埋め込むためには前後に空行を必要とする
        text = "<div>aaa</div>"

        expect(markdown(text)).to include "<div>aaa</div>"
      end

      # 適用されないため削除
      # xit "#の後に空白が無ければ見出しと認めないこと" do
      #   text = "#aaa"

      #   expect(markdown(text)).not_to include "h1"
      # end

      it "上付き文字を解析すること" do
        text = "10^3"

        expect(markdown(text)).to include "10<sup>3</sup>"
      end

      it "強調を解析すること" do
        text = "__aaa__"

        expect(markdown(text)).to include "<strong>aaa</strong>"
      end

      # 適用されないため削除
      # xit "ハイライトを解析すること" do
      #   text = "==aaa=="

      #   expect(markdown(text)).to include "<mark>aaa</mark>"
      # end

      it "引用符を解析すること" do
        text = ">aaa"

        expect(markdown(text)).to include "<blockquote>"
      end

      it "注釈と脚注リンクを解析すること" do
        text = <<~EOS
          aaa [^1]
          [^1]: #footnotes_1
        EOS

        expect(markdown(text)).to include %(<a href="#footnotes_1"><sup>1</sup></a>)
      end
    end

    describe "シンタックスハイライト" do
      context "sqlの場合" do
        it "シンタックスハイライトが適用されること" do
          text = <<~EOS
            ```sql:sample.sql
            SELECT *
             FROM table;
             WHERE id = id;
            ```
          EOS

          expect(markdown(text)).to include %(<div class="CodeRay">)
        end
      end

      context "rbの場合" do
        it "シンタックスハイライトが適用されること" do
          text = <<~EOS
            ```rb:sample.rb
            def aaa
              puts "aaa"
            end
            ```
          EOS

          expect(markdown(text)).to include %(<div class="CodeRay">)
        end
      end

      context "ymlの場合" do
        it "シンタックスハイライトが適用されること" do
          text = <<~EOS
            ```yml:sample.yml
            aaa: "aaa"
            ```
          EOS

          expect(markdown(text)).to include %(<div class="CodeRay">)
        end
      end

      context "その他の場合" do
        it "シンタックスハイライトが適用されること" do
          text = <<~EOS
            ```
            def aaa
              puts "aaa"
            end
            ```
          EOS

          expect(markdown(text)).to include %(<div class="CodeRay">)
        end
      end
    end
  end

  describe "#toc" do
    it "マークダウンからネストされた目次を生成すること" do
      text = <<~EOS
        # aaa
        ## bbb
        ### ccc
      EOS

      result = <<~EOS
        <ul>
        <li>
        <a href="#toc_0">aaa</a>
        <ul>
        <li>
        <a href="#toc_1">bbb</a>
        <ul>
        <li>
        <a href="#toc_2">ccc</a>
        </li>
        </ul>
        </li>
        </ul>
        </li>
        </ul>
      EOS

      expect(toc(text)).to eq result
    end
  end

  describe "#plaintext" do
    it "マークダウンからプレーンテキストを抽出すること" do
      text = <<~EOS
        # aaa
        ## bbb
        ### ccc
      EOS

      result = <<~EOS
        aaa
        bbb
        ccc
      EOS

      expect(plaintext(text)).to eq result
    end
  end
end
