class SearchesController < ApplicationController
  def index
    @keyword = params[:keyword]

    # キーワードに前後のスペースがあれば削除する
    @keyword &&= @keyword.gsub(/(^[[:space:]]+)|([[:space:]]+$)/, "")

    # 空文字などでは検索しない
    if @keyword.blank?
      @articles = Article.none.page(params[:page])
      return
    end

    # スラッグ、タイトル、概要、コンテンツから、大文字小文字を無視して部分一致検索する
    @articles = Article.ransack(slug_or_title_or_summary_or_content_i_cont: @keyword)
      .result.order(updated_at: :desc).page(params[:page])

    # 非公開記事はフィルタリングする
    @articles = login_filter(@articles)
  end
end
