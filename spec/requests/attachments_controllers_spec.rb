require 'rails_helper'

RSpec.describe "AttachmentsControllers", type: :request do
  describe "GET /attachments_controllers" do
    it "works! (now write some real specs)" do
      get attachments_controllers_path
      expect(response).to have_http_status(200)
    end
  end
end
