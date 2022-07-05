module MarkdownHelper
  require "redcarpet"
  require "redcarpet/render_strip"
  require "coderay"

  # マークダウンをHTMLに変換する
  def markdown(text)
    # レンダラーのオプション
    options = {
      with_toc_data: true, # 見出しにアンカーを付ける
      hard_wrap: true # 改行を<br>に変換する
    }

    # パーサーの拡張機能
    extensions = {
      no_intra_emphasis: true, # 単語内の_を解析しない
      tables: true, # テーブル
      fenced_code_blocks: true, # ~~~複数行のコードブロック~~~
      autolink: true, # <>で囲ってないリンクも解析する
      # disableindentedcodeblocks: true, # 通常記法のコードブロックを解析しない
      strikethrough: true, # ~~打ち消し線~~
      lax_spacing: true, # ブロックレベルのHTML要素の前後の空行を不要にする
      # spaceafterheaders: true, # #の後に空白が無ければ見出しと認めない
      superscript: true, # ^上付き文字
      underline: true, # _強調_
      # highlight: true, # ==ハイライト==
      quote: true, # >引用符
      footnotes: true # 注釈[^1]、[^1]: 脚注リンク
    }

    renderer = CustomRender.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)
    markdown.render(text).html_safe
  end

  # レンダラーのカスタムクラス
  class CustomRender < Redcarpet::Render::HTML
    # コードブロックにシンタックスハイライトを適用する
    def block_code(code, language)
      language &&= language.split(":")[0]

      # CodeRayの記法に合わせる
      case language.to_s
      when "rb"
        language = "ruby"
      when "yml"
        language = "yaml"
      when ""
        language = "md"
      end

      # インラインCSSスタイルでシンタックスハイライトを適用する
      CodeRay.scan(code, language).div
    end

    # テーブルをdivタグで囲って出力する
    def table(header, body)
      %(<div class="table-wrapper"><table>#{header}#{body}</table></div>)
    end
  end

  # 目次を生成する
  def toc(text)
    extensions = {
      nesting_level: 1..3 # h1からh3まで目次を作成する
    }

    renderer = Redcarpet::Render::HTML_TOC
    markdown = Redcarpet::Markdown.new(renderer, extensions)
    markdown.render(text).html_safe
  end

  # プレーンテキストに変換する
  def plaintext(text)
    renderer = Redcarpet::Render::StripDown
    markdown = Redcarpet::Markdown.new(renderer)
    markdown.render(text)
  end

  # マークダウンファイルを読み込む
  def markdown_file(path)
    return unless File.exist?(path)

    lines = File.read(path)
    markdown(lines)
  end
end
