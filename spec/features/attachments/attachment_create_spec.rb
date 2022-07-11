require "rails_helper"
require "dropybara"

RSpec.feature "Attachments::AttachmentCreates", type: :feature, js: true do
  given!(:user) { create(:user) }
  given!(:article) { create(:article) }

  background do
    sign_in user
    visit edit_category_article_path(article.category, article)
  end

  # 技術不足によりCodeMirrorへのファイルD&Dが再現できないためスキップ
  xfeature "画像投稿機能" do
    context "入力値が無効な場合" do
      scenario "投稿に失敗し、アラートが表示されること" do
        count = Attachment.count

        # アラートが表示されること
        accept_alert do
          within ".CodeMirror" do
            # Click makes CodeMirror element active:
            current_scope.click
          end

          # ファイルをD&Dする
          file_path = Rails.root.join("spec/fixtures/5MB.png")
          page.drop_file(".CodeMirror", file_path)

          # Ajaxの処理完了を待機する
          sleep 3
        end

        # 投稿に失敗すること
        expect(Attachment.count).to eq count
      end
    end

    context "入力値が有効な場合" do
      scenario "投稿に成功し、コンテンツ内に画像パスが追加されること" do
        count = Attachment.count

        within ".CodeMirror" do
          # Click makes CodeMirror element active:
          current_scope.click
        end

        # ファイルをD&Dする
        file_path = Rails.root.join("spec/fixtures/5MB.png")
        page.drop_file(".CodeMirror", file_path)

        # Ajaxの処理完了を待機する
        sleep 3

        # 投稿に成功すること
        expect(Attachment.count).to eq(count + 1)

        within ".CodeMirror" do
          # Click makes CodeMirror element active:
          current_scope.click

          # Find the hidden textarea:
          field = current_scope.find("textarea", visible: false)

          # コンテンツ内に画像パスが追加されること
          image_path = URI.parse(url_for(Attachment.last.image)).path
          expect(field.value).to include "![file](#{image_path})"
        end
      end
    end
  end
end
