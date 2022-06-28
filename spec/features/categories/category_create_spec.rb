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

  feature "カテゴリー作成ページのレイアウト" do
    context "トップページから作成する場合" do
      scenario "入力項目一覧が表示され、初期値が入力されていること" do
        visit root_path

        click_on "カテゴリー作成"

        expect(page).to have_current_path new_category_path, ignore_query: true

        expect(find_field("スラッグ名").text).to be_blank

        expect(find_field("タイトル").text).to be_blank

        expect(find_field("サマリー").text).to be_blank

        expect(page).to have_field "カテゴリーの並び順",
                                   with: Category.root_categories.count + 1

        # 親カテゴリーIDは空欄になっていること
        expect(find_field("親カテゴリーID").text).to be_blank

        expect(page).to have_button "新規作成"
      end
    end

    context "カテゴリー詳細ページから作成する場合" do
      scenario "入力項目一覧が表示され、初期値が入力されていること" do
        visit category_path(root_category)

        click_on "カテゴリー作成"

        expect(page).to have_current_path new_category_path, ignore_query: true

        expect(find_field("スラッグ名").text).to be_blank

        expect(find_field("タイトル").text).to be_blank

        expect(find_field("サマリー").text).to be_blank

        expect(page).to have_field "カテゴリーの並び順",
                                   with: root_category.child_categories.count + 1

        expect(page).to have_field "親カテゴリーID", with: root_category.id

        expect(page).to have_button "新規作成"
      end
    end
  end

  feature "カテゴリー作成機能" do
    background do
      visit new_category_path
    end

    context "入力値が無効な場合" do
      scenario "カテゴリーが作成されず、エラーが表示されること" do
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
        expect(error_elements.count).to eq(invalid_fields.count * 2)
      end
    end

    context "入力値が有効な場合" do
      scenario "カテゴリーが作成され、フラッシュが表示されること" do
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
        expect(page).to have_current_path category_path(Category.last), ignore_query: true

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
