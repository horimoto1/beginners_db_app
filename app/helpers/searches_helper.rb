module SearchesHelper
  # 文字列からキーワードを含む部分文字列を抽出する
  def extract_substring(text, keywords, max_length = 100)
    # 文字列を文単位で区切る
    ps = PragmaticSegmenter::Segmenter.new(text: text, language: "jp")

    # キーワードに一致するパターンを生成する
    keywords = keywords.map { |keyword| Regexp.escape(keyword) }
    pattern = /#{keywords.join("|")}/i

    result = ""

    # 最初にキーワードが見つかった文を先頭に部分文字列を抽出する
    ps.segment.each do |segment|
      if pattern.match?(segment) || !result.empty?
        result += "#{segment} "
      end
    end

    # キーワードが見つからなければ最初の文から抽出する
    ps.segment.each { |segment| result += "#{segment} " } if result.empty?

    # 指定の文字数で切り捨てる
    result = result.truncate(max_length)

    # キーワードを太字にする
    result.gsub!(pattern) { "<b>#{$&}</b>" }
    result.html_safe
  end
end
