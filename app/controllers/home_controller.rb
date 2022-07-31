class HomeController < ApplicationController
  before_action :set_edit_menu

  def top
    # 最新の記事一覧を取得する
    @articles = Article.order(updated_at: :desc).page(params[:page]).per(5)

    # ログイン状態に基づきフィルタリングする
    unless user_signed_in?
      @articles = @articles.published
    end

    # 必要なレコードを先読みする
    @articles = @articles.with_category.with_attached_image
  end

  private

  def set_edit_menu
    return unless user_signed_in?

    @edit_menu_list = [
      { text: "カテゴリーを作成する", path: new_category_path, action: "new" }
    ]
  end
end
