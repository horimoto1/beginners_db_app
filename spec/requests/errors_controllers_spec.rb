require 'rails_helper'

RSpec.describe "ErrorsControllers", type: :request do
  describe "GET /errors_controllers" do
    it "works! (now write some real specs)" do
      get errors_controllers_path
      expect(response).to have_http_status(200)
    end
  end
end
