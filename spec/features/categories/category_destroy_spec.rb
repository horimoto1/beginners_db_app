require "rails_helper"

RSpec.feature "Categories::CategoryDestroys", type: :feature, js: true do
  given!(:user) { create(:user) }
  given!(:root_category) { create(:category) }
  given!(:articles) {
    create_list(:article, 3,
                category_id: root_category.id)
  }
  given!(:child_categories) {
    create_list(:category, 3,
                parent_category_id: root_category.id)
  }

  background do
    sign_in user
    visit category_path(root_category)
  end

  context "確認ダイアログでキャンセルを選択する" do
    scenario "カテゴリーが削除されないこと" do
      count = Category.count

      dismiss_confirm "本当に削除しますか？" do
        click_on "カテゴリー削除"
      end

      # Ajaxの処理完了を待機する
      sleep 1

      expect(Category.count).to eq count
    end
  end

  context "確認ダイアログでOKを選択する" do
    scenario "カテゴリーが削除され、フラッシュが表示されること" do
      accept_alert "本当に削除しますか？" do
        click_on "カテゴリー削除"
      end

      # Ajaxの処理完了を待機する
      sleep 1

      # カテゴリーが削除されること
      expect(Category.where(id: root_category.id).count).to eq 0

      # 記事が削除されること
      expect(Article.where(category_id: root_category.id).count).to eq 0

      # 子カテゴリーが削除されること
      expect(Category.where(parent_category_id: root_category.id).count).to eq 0

      # トップページに遷移すること
      expect(page.current_path).to eq root_path

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
