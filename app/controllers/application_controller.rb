class ApplicationController < ActionController::Base
  include ApplicationHelper
  include ApplicationError

  # 例外処理
  rescue_from StandardError, with: :render_500
  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from ActionController::RoutingError, with: :render_404
  rescue_from ApplicationError::NotPublishedError, with: :not_published

  before_action :set_menu

  private

  def set_menu
    @root_categories = Category.root_categories.sorted
  end

  def render_404(exception = nil)
    if exception
      logger.info "Rendering 404 with exception: #{exception.message}"
    end

    render template: "errors/error_404", status: 404, layout: "application"
  end

  def render_500(exception = nil)
    if exception
      logger.info "Rendering 500 with exception: #{exception.message}"
    end

    render template: "errors/error_500", status: 500, layout: "application"
  end

  def not_published(exception = nil)
    @message = exception.message if exception
    render template: "errors/not_published", status: 404, layout: "application"
  end
end
