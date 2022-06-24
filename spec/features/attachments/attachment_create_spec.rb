require "rails_helper"

RSpec.feature "Attachments::AttachmentCreates", type: :feature, js: true do
  given!(:user) { create(:user) }
  given!(:article) { create(:article) }

  background do
    sign_in user
    visit edit_category_article_path(article.category, article)
  end

  # ファイルのD&Dが再現できなかったのでスキップする
  xfeature "画像投稿機能" do
    context "入力値が無効な場合" do
      scenario "投稿に失敗し、アラートが表示されること" do
        count = Attachment.count

        # アラートが表示されること
        accept_alert do
          # ファイルをD&Dする
          page.drop_file("コンテンツ", "/spec/fixtures/5MB.png")

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

        # ファイルをD&Dする
        page.drop_file("コンテンツ", "/spec/fixtures/kitten.jpg")

        # Ajaxの処理完了を待機する
        sleep 3

        # 投稿に成功すること
        expect(Attachment.count).to eq (count + 1)

        # コンテンツ内に画像パスが追加されること
        image_path = URI.parse(url_for(Attachment.last.image)).path
        content = find_field("コンテンツ")
        expect(content.value).to include "![file](#{image_path})"
      end
    end
  end
end
