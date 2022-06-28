require "rails_helper"

RSpec.describe "Searches", type: :request do
  describe "GET /searches to #index" do
    let!(:base_title) { "BeginnersDB" }

    before do
      get searches_path(keyword: "test")
    end

    it "取得に成功すること" do
      expect(response).to have_http_status(:ok)
    end

    it "タイトルが正しいこと" do
      expect(response.body).to include "検索結果 | #{base_title}"
    end
  end
end
