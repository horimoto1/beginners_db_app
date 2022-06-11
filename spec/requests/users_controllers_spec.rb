require "rails_helper"

RSpec.describe "UsersControllers", type: :request do
  let(:base_title) { "BeginnersDB" }

  describe "GET /profile to #show" do
    before do
      get profile_path
    end

    it "取得に成功すること" do
      expect(response).to have_http_status(200)
    end

    it "タイトルが正しいこと" do
      expect(response.body).to include "プロフィール | #{base_title}"
    end
  end
end
