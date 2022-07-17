require "rails_helper"

RSpec.describe "HomeControllers", type: :request do
  describe "GET / to #top" do
    before do
      get root_url
    end

    it "取得に成功すること" do
      expect(response).to have_http_status(:ok)
    end
  end
end
