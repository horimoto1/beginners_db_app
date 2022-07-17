require "rails_helper"

RSpec.feature "Home::HomeTops", type: :feature do
  feature "トップページのレイアウト" do
    given!(:root_categories) { create_list(:category, 3) }

    scenario "タイトルが正しいこと" do
      visit root_path

      expect(page).to have_title "DB入門"
    end

    scenario "見出しが表示されること" do
      visit root_path

      # 見出しが表示されること
      within "div.heading" do
        expect(page).to have_selector "h1", text: "TOP PAGE"
      end
    end

    scenario "メニューが表示されること" do
      visit root_path

      # メニューが表示されること
      within "div.top-menu" do
        # ルートカテゴリーへのリンクが表示されること
        root_categories.each do |root_category|
          expect(page).to have_link root_category.title,
                                    href: category_path(root_category)
        end
      end
    end

    context "ログアウト時" do
      scenario "編集メニューが表示されないこと" do
        visit root_path

        expect(page).to have_no_selector "label[for=edit-menu-toggle]"
      end
    end

    context "ログイン時" do
      given!(:user) { create(:user) }

      scenario "編集メニューが表示されること" do
        sign_in user
        visit root_path

        find("label[for=edit-menu-toggle]").click
        within "div.edit-menu" do
          # カテゴリー作成ページへのリンクが表示されること
          expect(page).to have_link "カテゴリーを作成する", href: new_category_path
        end
      end
    end
  end
end
