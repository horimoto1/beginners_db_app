require "rails_helper"

RSpec.describe "HomeControllers", type: :request do
  describe "GET / to #top" do
    let!(:base_title) { "BeginnersDB" }

    before do
      get root_url
    end

    it "取得に成功すること" do
      expect(response).to have_http_status(:ok)
    end

    it "タイトルが正しいこと" do
      expect(response.body).to include base_title
    end
  end
end
