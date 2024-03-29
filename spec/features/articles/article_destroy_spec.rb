require "rails_helper"

RSpec.feature "Articles::ArticleDestroys", type: :feature, js: true do
  given!(:user) { create(:user) }
  given!(:article) { create(:article, published: true) }

  background do
    sign_in user
    visit category_article_path(article.category, article)
  end

  feature "記事削除機能" do
    context "確認ダイアログでキャンセルを選択する" do
      scenario "記事が削除されないこと" do
        count = Article.count

        dismiss_confirm "本当に削除しますか？" do
          find("label[for=edit-menu-toggle]").click
          click_on "記事を削除する"
        end

        # Ajaxの処理完了を待機する
        sleep 1

        expect(Article.count).to eq count
      end
    end

    context "確認ダイアログでOKを選択する" do
      scenario "記事が削除され、フラッシュが表示されること" do
        accept_alert "本当に削除しますか？" do
          find("label[for=edit-menu-toggle]").click
          click_on "記事を削除する"
        end

        # Ajaxの処理完了を待機する
        sleep 1

        # 記事が削除されること
        expect(Article.where(id: article.id).count).to eq 0

        # カテゴリー詳細ページに遷移すること
        expect(page).to have_current_path category_path(article.category), ignore_query: true

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
