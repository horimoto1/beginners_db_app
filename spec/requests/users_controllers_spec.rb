require "rails_helper"

RSpec.describe "UsersControllers", type: :request do
  describe "GET /profile to #show" do
    before do
      get profile_path
    end

    it "取得に成功すること" do
      expect(response).to have_http_status(:ok)
    end
  end
end
