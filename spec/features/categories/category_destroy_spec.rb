require "rails_helper"

RSpec.feature "Categories::CategoryDestroys", type: :feature, js: true do
  given!(:user) { create(:user) }
  given!(:category) { create(:category) }

  background do
    sign_in user
    visit category_path(category)
  end

  feature "カテゴリー削除機能" do
    context "確認ダイアログでキャンセルを選択する" do
      scenario "カテゴリーが削除されないこと" do
        count = Category.count

        dismiss_confirm "本当に削除しますか？" do
          find("label[for=edit-menu-toggle]").click
          click_on "カテゴリーを削除する"
        end

        # Ajaxの処理完了を待機する
        sleep 1

        expect(Category.count).to eq count
      end
    end

    context "確認ダイアログでOKを選択する" do
      scenario "カテゴリーが削除され、フラッシュが表示されること" do
        accept_alert "本当に削除しますか？" do
          find("label[for=edit-menu-toggle]").click
          click_on "カテゴリーを削除する"
        end

        # Ajaxの処理完了を待機する
        sleep 1

        # カテゴリーが削除されること
        expect(Category.where(id: category.id).count).to eq 0

        # トップページに遷移すること
        expect(page).to have_current_path root_path, ignore_query: true

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
