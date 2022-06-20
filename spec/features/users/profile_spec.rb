require "rails_helper"

RSpec.feature "Users::Profiles", type: :feature do
  feature "プロフィールのレイアウト" do
    scenario "見出しが表示されること" do
      visit root_path

      within "footer" do
        click_on "プロフィール"
      end

      expect(page.current_path).to eq profile_path

      # 見出しが表示されること
      within "div.heading" do
        expect(page).to have_selector "h1", text: "プロフィール"
      end
    end
  end
end