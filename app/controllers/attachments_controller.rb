class AttachmentsController < ApplicationController
  def create
    attachment = Attachment.new
    attachment.image.attach(params[:image])
    if attachment.save
      render json: { filename: url_for(attachment.image) }
    else
      render json: {}
    end
  end

  def destroy
    attachment = Attachment.find(params[:id])
    attachment.image.purge if attachment.image.attached?
    attachment.destroy
    render json: {}
  end
end
