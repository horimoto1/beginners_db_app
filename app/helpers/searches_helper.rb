module SearchesHelper
  # 文字列からキーワードを含む部分文字列を抽出する
  def extract_substring(text, keywords, max_length = 100)
    # 文単位で区切る
    ps = PragmaticSegmenter::Segmenter.new(text: text, language: "jp")

    keywords = keywords.map { |keyword| Regexp.escape(keyword) }
    pattern = /#{keywords.join("|")}/

    result = ""

    # 最初にキーワードが見つかった文を先頭に指定の文字数を抽出する
    ps.segment.each do |segment|
      if result.empty? && pattern.match?(segment) ||
         !result.empty? && result.length < max_length
        result += segment
      end
    end

    # キーワードが見つからなければ先頭から指定の文字数を抽出する
    if result.empty?
      ps.segment.each do |segment|
        if result.length < max_length
          result += segment
        end
      end
    end

    # 指定の文字数で切り捨てる
    result = truncate(result, length: max_length)

    # キーワードを太字にする
    result = result.gsub(pattern) { "<b>#{$&}</b>" }
    result.html_safe
  end
end
