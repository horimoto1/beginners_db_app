class ApplicationController < ActionController::Base
  before_action :set_menu

  private

  def set_menu
    @root_categories = Category.root_categories
  end
end
