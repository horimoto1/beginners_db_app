require "rails_helper"

RSpec.feature "Attachments::AttachmentCreates", type: :feature, js: true do
  given!(:user) { create(:user) }
  given!(:article) { create(:article) }

  background do
    sign_in user
    visit edit_category_article_path(article.category, article)
  end

  feature "画像投稿機能" do
    context "入力値が無効な場合" do
      scenario "投稿に失敗し、アラートが表示されること" do
        count = Attachment.count

        # アラートが表示されること
        accept_alert do
          # ファイルをD&Dする
          file_path = Rails.root.join("spec/fixtures/5MB.png")
          drop_file_editor_field(file_path)

          # Ajaxの処理完了を待機する
          sleep 3
        end

        # 投稿に失敗すること
        expect(Attachment.count).to eq count

        # コンテンツ内に空の画像パスが追加されること
        text_area = find("#article_content", visible: false)
        expect(text_area.value).to include "![](http://)"
      end
    end

    context "入力値が有効な場合" do
      scenario "投稿に成功し、コンテンツ内に画像パスが追加されること" do
        count = Attachment.count

        # ファイルをD&Dする
        file_path = Rails.root.join("spec/fixtures/kitten.jpg")
        drop_file_editor_field(file_path)

        # Ajaxの処理完了を待機する
        sleep 3

        # 投稿に成功すること
        expect(Attachment.count).to eq(count + 1)

        # コンテンツ内に投稿した画像の画像パスが追加されること
        image_path = URI.parse(url_for(Attachment.last.image)).path
        text_area = find("#article_content", visible: false)
        expect(text_area.value).to include "![kitten.jpg](#{image_path})"
      end
    end

    private

    # CodeMirrorにファイルをドラッグアンドドロップする
    def drop_file_editor_field(file_path)
      # ダミーのファイル選択フォームを追加する
      page.execute_script <<-JS
        fakeFileInput = window.$("<input/>").attr(
          {id: "fakeFileInput", type:"file"}
        ).appendTo("body")
      JS

      # ダミーのファイル選択フォームにファイルをアタッチする
      attach_file("fakeFileInput", file_path)

      # ファイルのドロップイベントを発火する
      page.execute_script <<-JS
        let fileList = [fakeFileInput.get(0).files[0]]
        let editor = document.querySelector(".CodeMirror").CodeMirror
        let event = jQuery.Event("drop", { dataTransfer : { files : fileList } })
        editor.constructor.signal(editor, "drop", editor, event)
      JS
    end
  end
end
