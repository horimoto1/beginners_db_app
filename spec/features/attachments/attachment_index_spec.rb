require "rails_helper"

RSpec.feature "Attachments::AttachmentIndices", type: :feature do
  given!(:user) { create(:user) }
  given!(:attachments) { create_list(:attachment, 20) }

  background do
    sign_in user
  end

  feature "画像一覧ページのレイアウト" do
    scenario "見出し、画像一覧、ページネーションが表示されること" do
      visit root_path

      within "footer" do
        click_on "画像一覧"
      end

      expect(page.current_path).to eq attachments_path

      # 見出しが表示されること
      within "div.heading" do
        expect(page).to have_selector "h1", text: "画像一覧"
        expect(page).to have_content "20件中の1～10件目を表示しています。"
      end

      # 画像一覧が表示されること
      within "div.image-list" do
        Attachment.all.order(created_at: :desc).limit(10).each do |attachment|
          within "li#image-item-#{attachment.id}" do
            "画像が表示されること"
            expect(page).to have_selector "img"

            "各画像に画像パスのコピーボタンが表示されること"
            within "li.copy-to-clip" do
              copy_text = find_field("copy-text-#{attachment.id}")
              expect(copy_text.readonly?).to eq true
              expect(copy_text.value).to eq URI.parse(url_for(attachment.image)).path
              expect(page).to have_button
            end

            "各画像に削除ボタンが表示されること"
            expect(page).to have_link "削除",
                                      href: attachment_path(attachment)
          end
        end
      end

      # ページネーションが表示されること
      within "nav.pagination" do
        # 2ページ目のリンクが表示されること
        expect(page).to have_link "2", href: attachments_path(page: 2)
      end
    end

    context "画像がアタッチされなかった場合" do
      given!(:no_attachment) {
        create(:attachment, image: nil,
                            content_type: nil)
      }

      scenario "画像がアタッチされていない場合は警告文を表示すること" do
        visit attachments_path

        within "div.image-list" do
          within "li#image-item-#{no_attachment.id}" do
            "警告文が表示されること"
            expect(page).to have_content "画像がアタッチされていません。"

            "画像が表示されないこと"
            expect(page).to have_no_selector "img"

            "画像パスのコピーボタンが表示されないこと"
            expect(page).to have_no_selector "li.copy-to-clip"

            "削除ボタンが表示されること"
            expect(page).to have_link "削除",
                                      href: attachment_path(no_attachment)
          end
        end
      end
    end
  end
end
