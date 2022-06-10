require "rails_helper"

RSpec.describe "HomeControllers", type: :request do
  let(:base_title) { "BeginnersDB" }

  describe "#top" do
    it "アクセスできること" do
      get root_url
      expect(response).to have_http_status(200)
    end

    it "タイトルが正しいこと" do
      get root_url
      # expect(response).to have_title base_title
      expect(response.body).to include base_title
    end
  end
end
