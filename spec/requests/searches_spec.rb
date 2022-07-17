require "rails_helper"

RSpec.describe "Searches", type: :request do
  describe "GET /searches to #index" do
    before do
      get searches_path(keyword: "test")
    end

    it "取得に成功すること" do
      expect(response).to have_http_status(:ok)
    end
  end
end
