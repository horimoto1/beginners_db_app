class ApplicationController < ActionController::Base
  include ApplicationHelper
  include ApplicationError

  # 例外処理
  rescue_from StandardError, with: :server_error
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::RoutingError, with: :not_found
  rescue_from ApplicationError::NotPublishedError, with: :not_published
  rescue_from CanCan::AccessDenied, with: :access_denied

  before_action :set_menu

  private

  def set_menu
    @root_categories = Category.root_categories.sorted
  end

  def not_found(exception = nil)
    if exception
      logger.info "Rendering 404 with exception: #{exception.message}"
    end

    render template: "errors/error_404", status: :not_found, layout: "application"
  end

  def server_error(exception = nil)
    if exception
      logger.info "Rendering 500 with exception: #{exception.message}"
    end

    render template: "errors/error_500", status: :internal_server_error, layout: "application"
  end

  def not_published(exception = nil)
    @message = exception.message if exception
    render template: "errors/not_published", status: :not_found, layout: "application"
  end

  def access_denied
    message = "アクセス権限がありません"

    respond_to do |format|
      format.html do
        flash.now[:alert] = message
        render template: "home/top", status: :forbidden, layout: "application"
      end
      format.json do
        render json: { errors: [message] }, status: :forbidden
      end
    end
  end
end
