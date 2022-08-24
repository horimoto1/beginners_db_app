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

      # 適用されないため保留
      # it "通常記法のコードブロックを解析しないこと" do
      #   # 通常記法では、各行の先頭にある4つのスペースを持つテキストをコードブロックに変換する
      #   text = <<-EOS
      #     SELECT *
      #     FROM table;
      #     WHERE id = id;
      #   EOS

      #   expect(markdown(text)).not_to include %(<div class="code">)
      # end

      it "打ち消し線を解析すること" do
        text = "~~aaa~~"

        expect(markdown(text)).to include "<del>aaa</del>"
      end

      it "前後の空行がないブロックレベルのHTML要素を出力すること" do
        # 通常記法では、ブロックレベルのHTML要素を埋め込むためには前後に空行を必要とする
        text = "<div>aaa</div>"

        expect(markdown(text)).to include "<div>aaa</div>"
      end

      # 適用されないため保留
      # it "#の後に空白が無ければ見出しと認めないこと" do
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

      it "ハイライトを解析すること" do
        text = "==aaa=="

        expect(markdown(text)).to include "<mark>aaa</mark>"
      end

      it "引用符を解析すること" do
        text = ">aaa"

        expect(markdown(text)).to include "<blockquote>"
      end

      it "注釈と脚注を解析すること" do
        text = <<~EOS
          aaa [^1]
          [^1]: 脚注
        EOS

        expect(markdown(text)).to include %(<sup id="fnref1"><a href="#fn1">1</a></sup>)
        expect(markdown(text)).to include %(<li id="fn1">)
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
        <a href="#aaa">aaa</a>
        <ul>
        <li>
        <a href="#bbb">bbb</a>
        <ul>
        <li>
        <a href="#ccc">ccc</a>
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

  describe "#markdown_file" do
    context "ファイルが無い場合" do
      it "nilを返すこと" do
        path = Rails.root.join("spec/fixtures/nothing.md")
        expect(markdown_file(path)).to be_nil
      end
    end

    context "ファイルが存在する場合" do
      it "マークダウンをパースした結果を返すこと" do
        path = Rails.root.join("spec/fixtures/sample.md")
        expect(markdown_file(path)).to eq "<p>sample_text1<br>\nsample_text2</p>\n"
      end
    end
  end
end
