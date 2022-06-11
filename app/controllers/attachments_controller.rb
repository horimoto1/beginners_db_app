class AttachmentsController < ApplicationController
  before_action :authenticate_user!

  def create
    attachment = Attachment.new
    attachment.image.attach(params[:image])
    if attachment.save
      render json: { filename: url_for(attachment.image) }
    else
      render json: { filename: "画像のアップロードに失敗しました" }
    end
  end

  def destroy
    attachment = Attachment.find(params[:id])
    attachment.image.purge if attachment.image.attached?
    attachment.destroy
    render json: { filename: "画像を削除しました" }
  end
end
