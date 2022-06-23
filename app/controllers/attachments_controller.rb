class AttachmentsController < ApplicationController
  before_action :authenticate_user!

  def index
    @attachments = Attachment.all.order(created_at: :desc).page(params[:page])
  end

  def create
    @attachment = Attachment.new
    @attachment.image.attach(params[:image])
    @attachment.save
    render :create, formats: :json
  end

  def destroy
    @attachment = Attachment.find(params[:id])
    @attachment.image.purge if @attachment.image.attached?
    @attachment.destroy
    flash[:success] = "画像を削除しました"
    redirect_to attachments_path
  end
end
