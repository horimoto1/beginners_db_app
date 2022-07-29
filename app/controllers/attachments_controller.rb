class AttachmentsController < ApplicationController
  before_action :authenticate_user!
  authorize_resource only: [:create, :destroy]

  def index
    @attachments = Attachment.all.order(created_at: :desc).page(params[:page])

    # 事前に画像一覧をキャッシュしておく
    @attachments = @attachments.with_attached_image
  end

  def create
    @attachment = Attachment.new
    @attachment.image.attach(params[:image])
    @attachment.save
    render :create, formats: :json
  end

  def destroy
    @attachment = Attachment.find(params[:id])
    # @attachment.image.purge if @attachment.image.attached?
    @attachment.destroy
    flash[:success] = "画像を削除しました"

    if request.referer && URI(request.referer).path == attachments_path
      redirect_to request.referer
    else
      redirect_to attachments_path
    end
  end
end
