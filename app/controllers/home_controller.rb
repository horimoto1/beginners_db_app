class HomeController < ApplicationController
  before_action :set_edit_menu

  def top; end

  private

  def set_edit_menu
    return unless user_signed_in?

    @edit_menu_list = [
      { text: "カテゴリーを作成する", path: new_category_path, action: "new" }
    ]
  end
end
