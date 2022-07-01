class SearchesController < ApplicationController
  def index
    @keywords = analyse_keyword(params[:keyword])

    # キーワードが無ければ検索しない
    if @keywords.blank?
      @articles = Article.none.page(params[:page])
      return
    end

    # スラッグ、タイトル、概要、コンテンツから、大文字小文字を無視して部分一致でAND検索する
    @articles = Article.ransack(slug_or_title_or_summary_or_content_i_cont_all: @keywords).result
                       .order(updated_at: :desc).page(params[:page])

    # ログイン状態に基づきフィルタリングする
    unless user_signed_in?
      @articles = @articles.published
    end

    # 事前にカテゴリーをキャッシュしておく
    @articles = @articles.with_category
  end

  private

  # キーワードを分析する
  def analyse_keyword(keyword)
    return [] if keyword.blank?

    # キーワードに前後のスペースがあれば削除する
    keyword.gsub!(/(^[[:space:]]+)|([[:space:]]+$)/, "")

    # キーワードをスペースで分割する
    keyword.split(/[[:space:]]/).reject(&:blank?)
  end
end
