class AttachmentsController < ApplicationController
  before_action :authenticate_user!

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
    render :destroy, formats: :json
  end
end
