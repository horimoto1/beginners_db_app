require "rails_helper"

RSpec.feature "HomeTops", type: :feature do
  feature "トップページのレイアウト" do
    given!(:root_categories) { create_list(:category, 3) }

    scenario "見出し、メニューが表示されること" do
      visit root_path

      # 見出しが表示されること
      within "div.heading" do
        expect(page).to have_selector "h1", text: "TOP PAGE"
      end

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
      scenario "アクションメニューが表示されないこと" do
        visit root_path

        expect(page).to have_no_selector "div.action-menu"
      end
    end

    context "ログイン時" do
      given!(:user) { create(:user) }

      scenario "アクションメニューが表示されること" do
        sign_in user
        visit root_path

        within "div.action-menu" do
          # カテゴリー作成ページへのリンクが表示されること
          expect(page).to have_link "カテゴリー作成", href: new_category_path
        end
      end
    end
  end
end
