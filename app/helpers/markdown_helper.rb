module MarkdownHelper
  require "redcarpet"
  require "coderay"

  # マークダウンをHTMLに変換する
  def markdown(text)
    # レンダラーのオプション
    options = {
      with_toc_data: true, # 見出しにアンカーを付ける
      hard_wrap: true, # 改行を<br>に変換する
    }

    # パーサーの拡張機能
    extensions = {
      no_intra_emphasis: true, # 単語内の_を強調として解析しない
      tables: true, # テーブル
      fenced_code_blocks: true, # ~~~コードブロック~~~
      autolink: true, # <>で囲ってないリンクも解析する
      disableindentedcodeblocks: true, # 通常記法のコードブロックを解析しない
      strikethrough: true, # ~~打ち消し線~~
      lax_spacing: true, # 空行で囲ってないHTMLブロックも解析する
      spaceafterheaders: true, # 見出しの前の半角スペースを必須にする
      superscript: true, # ^上付き文字
      underline: true, # _強調_
      highlight: true, # ==ハイライト==
      quote: true, # "引用符"
      footnotes: true, # ^[脚注]
    }

    renderer = CustomRender.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)
    markdown.render(text).html_safe
  end

  # レンダラーのカスタムクラス
  class CustomRender < Redcarpet::Render::HTML
    # コードブロックに対して処理を行う
    def block_code(code, language)
      language = language.split(":")[0]

      case language.to_s
      when "rb"
        lang = "ruby"
      when "yml"
        lang = "yaml"
      when "css"
        lang = "css"
      when "html"
        lang = "html"
      when ""
        lang = "md"
      else
        lang = language
      end

      # コードブロックにシンタックスハイライトを適用する
      CodeRay.scan(code, lang).div
    end
  end

  # 目次を生成する
  def toc(text)
    extensions = {
      nesting_level: 3, # 3層まで目次をネストする
    }

    renderer = Redcarpet::Render::HTML_TOC.new
    markdown = Redcarpet::Markdown.new(renderer, extensions)
    markdown.render(text).html_safe
  end

  # プレーンテキストに変換する
  def plaintext(text)
    renderer = Redcarpet::Render::StripDown
    markdown = Redcarpet::Markdown.new(renderer)
    markdown.render(text)
  end
end
