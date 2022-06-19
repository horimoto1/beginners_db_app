require "rails_helper"

RSpec.feature "Categories::CategoryCreates", type: :feature do
  given!(:user) { create(:user) }
  given!(:root_categories) { create_list(:category, 3) }
  given!(:root_category) { root_categories[1] }
  given!(:child_categories) {
    create_list(:category, 3,
                parent_category_id: root_category.id)
  }

  background do
    sign_in user
  end

  context "トップページから作成する場合" do
    scenario "入力項目一覧が表示され、初期値が入力されていること" do
      visit root_path

      click_on "カテゴリー作成"

      expect(page.current_path).to eq new_category_path

      expect(find_field("スラッグ名").text).to be_blank

      expect(find_field("タイトル").text).to be_blank

      expect(find_field("サマリー").text).to be_blank

      expect(page).to have_field "カテゴリーの並び順",
                                 with: Category.root_categories.count + 1

      # 親カテゴリーIDは空欄になっていること
      expect(find_field("親カテゴリーID").text).to be_blank
    end
  end

  context "カテゴリー詳細ページから作成する場合" do
    scenario "入力項目一覧が表示され、初期値が入力されていること" do
      visit category_path(root_category)

      click_on "カテゴリー作成"

      expect(page.current_path).to eq new_category_path

      expect(find_field("スラッグ名").text).to be_blank

      expect(find_field("タイトル").text).to be_blank

      expect(find_field("サマリー").text).to be_blank

      expect(page).to have_field "カテゴリーの並び順",
                                 with: root_category.child_categories.count + 1

      expect(page).to have_field "親カテゴリーID", with: root_category.id
    end
  end

  context "入力値が無効な場合" do
    scenario "カテゴリーが作成されず、エラーが表示されること" do
      visit new_category_path

      invalid_fields = [{ locator: "スラッグ名", value: "" },
                        { locator: "タイトル", value: "" },
                        { locator: "カテゴリーの並び順", value: "" },
                        { locator: "親カテゴリーID", value: "-1" }]

      invalid_fields.each do |invalid_field|
        fill_in invalid_field[:locator], with: invalid_field[:value]
      end

      # カテゴリーが作成されないこと
      expect { click_on "新規作成" }.not_to change { Category.count }

      # エラーが表示されること
      expect(page).to have_selector "div.error_explanation"
      error_elements = all("div.field_with_errors")
      expect(error_elements.count).to eq (invalid_fields.count * 2)
    end
  end

  context "入力値が有効な場合" do
    scenario "カテゴリーが作成され、フラッシュが表示されること" do
      visit new_category_path

      valid_fields = [{ locator: "スラッグ名", value: "sample1" },
                      { locator: "タイトル", value: "サンプル1" },
                      { locator: "サマリー", value: "サンプル1" },
                      { locator: "カテゴリーの並び順", value: "1" },
                      { locator: "親カテゴリーID", value: "" }]

      valid_fields.each do |valid_field|
        fill_in valid_field[:locator], with: valid_field[:value]
      end

      # カテゴリーが作成されること
      expect { click_on "新規作成" }.to change { Category.count }.by(1)

      # カテゴリーの詳細ページに遷移すること
      expect(page.current_path).to eq category_path(Category.last)

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
