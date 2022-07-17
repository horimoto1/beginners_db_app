require "rails_helper"

RSpec.feature "Attachments::AttachmentDestroys", type: :feature, js: true do
  given!(:user) { create(:user) }
  given!(:attachment) { create(:attachment) }

  background do
    sign_in user
    visit attachments_path
  end

  feature "画像削除機能" do
    context "確認ダイアログでキャンセルを選択する" do
      scenario "画像が削除されないこと" do
        count = Attachment.count

        within "div.image-list" do
          within "li#image-item-#{attachment.id}" do
            dismiss_confirm "本当に削除しますか？" do
              click_on "destroy"
            end
          end
        end

        # Ajaxの処理完了を待機する
        sleep 1

        expect(Attachment.count).to eq count
      end
    end

    context "確認ダイアログでOKを選択する" do
      scenario "画像が削除され、フラッシュが表示されること" do
        within "div.image-list" do
          within "li#image-item-#{attachment.id}" do
            accept_alert "本当に削除しますか？" do
              click_on "destroy"
            end
          end
        end

        # Ajaxの処理完了を待機する
        sleep 1

        # 画像が削除されること
        expect(Attachment.where(id: attachment.id).count).to eq 0

        expect(page).to have_current_path attachments_path, ignore_query: true

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
