class SearchesController < ApplicationController
  def index
    @keyword = params[:keyword]

    # キーワードに前後のスペースがあれば削除する
    @keyword&.gsub!(/(^[[:space:]]+)|([[:space:]]+$)/, "")

    # キーワードを解析する
    analyse_keywords = analyse_keyword(@keyword)

    # キーワードが無ければ検索しない
    if analyse_keywords.blank?
      @articles = Article.none.page(params[:page])
      return
    end

    # 解析したキーワードから通常のキーワードを抽出する
    @positive_keywords = []
    analyse_keywords.each { |k| @positive_keywords.concat(k[0]) }

    # 解析したキーワードから検索条件を構築する
    query = build_search_conditions(analyse_keywords)

    # キーワードを検索する
    @articles = Article.ransack(query).result
                       .order(updated_at: :desc).page(params[:page])

    # ログイン状態に基づきフィルタリングする
    unless user_signed_in?
      @articles = @articles.published
    end

    # 事前にカテゴリーをキャッシュしておく
    @articles = @articles.with_category
  end

  private

  # キーワードを解析する
  def analyse_keyword(keyword)
    return [] if keyword.blank?

    # キーワードを分割する
    keywords = split_keyword(keyword)

    # LIKE述語の特殊記号をエスケープする
    keywords.map! { |k| ActiveRecord::Base.sanitize_sql_like(k) }

    # キーワードをグループ化する
    grouping_keyword(keywords)
  end

  # キーワードを分割する
  def split_keyword(keyword)
    return [] if keyword.blank?

    # フレーズ検索を考慮してキーワードを分割する
    keywords = keyword.scan(/(-?".+?")|(-?[^[:space:]]+)/)

    # scanでマッチした部分を取得する
    result = []
    keywords.each do |word|
      if word[0].present?
        result << word[0]
      elsif word[1].present?
        result << word[1]
      end
    end

    result
  end

  # キーワードをグループ化する
  def grouping_keyword(keywords)
    return [] if keywords.blank?

    # キーワードをOR条件で区切る
    keyword_groups = keywords.slice_when { |_a, b| b.match?(/^OR$/i) }.to_a

    result = []
    keyword_groups.each do |keyword_group|
      # ORキーワードは取り除く
      keyword_group.reject! { |k| k.match?(/^OR$/i) }
      next if keyword_group.blank?

      # 通常のキーワードと除外検索のキーワードを分ける
      negative_keywords, positive_keywords =
        keyword_group.partition { |k| k.match?(/^-/) }

      # 除外検索のキーワードは先頭の-を取り除く
      negative_keywords.each { |k| k.gsub!(/^-/, "") }

      # フレーズ検索のキーワードはダブルクォートを取り除く
      positive_keywords.each { |k| k.gsub!(/^"|"$/, "") }
      negative_keywords.each { |k| k.gsub!(/^"|"$/, "") }

      result << [positive_keywords, negative_keywords]
    end

    result
  end

  # 検索条件を構築する
  def build_search_conditions(keywords)
    return {} if keywords.blank?

    # 異なるグループの検索条件はORで繋げる
    q = { "g" => {}, "m" => "or" }

    # 各グループの検索条件を追加する
    keywords.each_with_index do |keyword, i|
      q["g"].store(
        i.to_s, {
          "g" => {
            # 通常の検索の検索条件
            "0" => {
              "slug_or_title_or_summary_or_content_i_cont_all" => keyword[0]
            },
            # 除外検索の検索条件
            "1" => {
              "slug_and_title_and_summary_and_content_not_i_cont_all" => keyword[1]
            }
          },
          # 同じグループの検索条件はANDで繋げる
          "m" => "and"
        }
      )
    end

    q
  end
end
