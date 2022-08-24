require "rails_helper"

RSpec.feature "Articles::Previews", type: :feature, js: true do
  given!(:user) { create(:user) }
  given!(:article) { create(:article, published: true) }

  background do
    sign_in user
  end

  feature "プレビュー機能" do
    context "記事投稿ページ" do
      background do
        visit new_category_article_path(article.category)
      end

      scenario "マークダウンのプレビューが表示できること" do
        fill_in_editor_field "# サンプル1\n## サン%プル2\n### サン プル3"

        button = first(".fa-eye")
        button.click

        # XHRの完了を待機する
        sleep 1

        # コンテンツが表示されること
        within "div.content" do
          # マークダウンのパース結果が表示されること
          expect(page).to have_selector "h1", text: "サンプル1"
          expect(page).to have_selector "h2", text: "サン%プル2"
          expect(page).to have_selector "h3", text: "サン プル3"
        end
      end
    end

    context "記事編集ページ" do
      background do
        visit edit_category_article_path(article.category, article)
      end

      scenario "マークダウンのプレビューが表示できること" do
        button = first(".fa-eye")
        button.click

        # XHRの完了を待機する
        sleep 1

        # コンテンツが表示されること
        within "div.content" do
          # マークダウンのパース結果が表示されること
          expect(page).to have_selector "h1", text: "テスト1"
          expect(page).to have_selector "h2", text: "テスト2"
          expect(page).to have_selector "h3", text: "テスト3"
        end
      end
    end

    private

    # CodeMirrorにテキストを入力する
    def fill_in_editor_field(text)
      within ".CodeMirror" do
        # Click makes CodeMirror element active:
        current_scope.click

        # Find the hidden textarea:
        field = current_scope.find("textarea", visible: false)

        # Mimic user typing the text:
        field.send_keys text
      end
    end
  end
end
