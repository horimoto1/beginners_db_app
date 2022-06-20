require "rails_helper"

RSpec.feature "Categories::CategoryUpdates", type: :feature do
  given!(:user) { create(:user) }
  given!(:root_category) { create(:category) }
  given!(:category) { create(:category, parent_category_id: root_category.id) }

  background do
    sign_in user
  end

  feature "カテゴリー編集ページのレイアウト" do
    scenario "入力項目一覧が表示され、初期値が入力されていること" do
      visit category_path(category)

      click_on "カテゴリー編集"

      expect(page.current_path).to eq edit_category_path(category)

      expect(page).to have_field "スラッグ名", with: category.name

      expect(page).to have_field "タイトル", with: category.title

      expect(page).to have_field "サマリー", with: category.summary

      expect(page).to have_field "カテゴリーの並び順", with: category.category_order

      expect(page).to have_field "親カテゴリーID", with: category.parent_category_id

      expect(page).to have_button "更新"
    end
  end

  feature "カテゴリー更新機能" do
    background do
      visit edit_category_path(category)
    end

    context "入力値が無効な場合" do
      scenario "カテゴリーが更新されず、エラーが表示されること" do
        invalid_fields = [{ locator: "スラッグ名", value: "" },
                          { locator: "タイトル", value: "" },
                          { locator: "カテゴリーの並び順", value: "" },
                          { locator: "親カテゴリーID", value: "-1" }]

        invalid_fields.each do |invalid_field|
          fill_in invalid_field[:locator], with: invalid_field[:value]
        end

        # カテゴリーが更新されないこと
        expect { click_on "更新" }.not_to change { category.reload.name }

        # エラーが表示されること
        expect(page).to have_selector "div.error_explanation"
        error_elements = all("div.field_with_errors")
        expect(error_elements.count).to eq (invalid_fields.count * 2)
      end
    end

    context "入力値が有効な場合" do
      scenario "カテゴリーが更新され、フラッシュが表示されること" do
        valid_fields = [{ locator: "スラッグ名", value: "sample1" },
                        { locator: "タイトル", value: "サンプル1" },
                        { locator: "サマリー", value: "サンプル1" },
                        { locator: "カテゴリーの並び順", value: "10" },
                        { locator: "親カテゴリーID", value: "" }]

        valid_fields.each do |valid_field|
          fill_in valid_field[:locator], with: valid_field[:value]
        end

        # カテゴリーが更新されること
        expect { click_on "更新" }.to change { category.reload.name }

        # カテゴリーの詳細ページに遷移すること
        expect(page.current_path).to eq category_path(category)

        # フラッシュが表示されること
        within "div.flash" do
          expect(page).to have_selector "p.success"
        end

        # リロードしたらフラッシュが消えること
        visit current_path
        expect(page).to have_no_selector "div.flash"
      end
    end
  end
end
