require "rails_helper"

RSpec.feature "Users::Profiles", type: :feature do
  feature "プロフィールのレイアウト" do
    scenario "タイトルが正しいこと" do
      visit profile_path

      expect(page).to have_title "プロフィール | DB入門"
    end

    scenario "見出しが表示されること" do
      visit root_path

      within "footer" do
        click_on "プロフィール"
      end

      expect(page).to have_current_path profile_path, ignore_query: true

      # 見出しが表示されること
      within "div.heading" do
        expect(page).to have_selector "h1", text: "プロフィール"
      end
    end
  end
end
