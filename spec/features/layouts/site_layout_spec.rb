require "rails_helper"

RSpec.feature "Layouts::SiteLayouts", type: :feature do
  feature "ヘッダーのレイアウト" do
    given!(:root_categories) { create_list(:category, 3) }

    background do
      visit root_path
    end

    scenario "ロゴが表示されること" do
      # ロゴが表示されること
      within "div.header-logo" do
        # トップページへのリンクが表示されること
        expect(page).to have_link nil, href: root_path
      end
    end

    context "画面幅が800pxより大きい場合", js: true do
      background do
        width = 1000 # 801pxだとパスしないため余裕を持って1000pxに調整
        height = 800
        current_window.resize_to(width, height)
      end

      scenario "検索フォームが表示されること" do
        # ヘッダーの検索フォームが表示されること
        within "div.header-nav" do
          expect(page).to have_field "keyword"
          expect(page).to have_button
        end
      end

      scenario "サイドメニューが表示されないこと" do
        # サイドメニューが表示されないこと
        expect(page).to have_no_selector "div.side-menu"
      end

      scenario "メニューバーが表示されること" do
        # メニューバーが表示されること
        within "div.menu-bar" do
          # トップページへのリンクが表示されること
          expect(page).to have_link nil, href: root_path

          # ルートカテゴリーへのリンクが表示されること
          root_categories.each do |root_category|
            expect(page).to have_link root_category.title,
                                      href: category_path(root_category)
          end
        end
      end
    end

    context "画面幅が800px以下の場合", js: true do
      background do
        width = 800
        height = 800
        current_window.resize_to(width, height)
      end

      scenario "ヘッダーの検索フォームが表示されないこと" do
        # ヘッダーの検索フォームが表示されないこと
        expect(page).to have_no_selector "div.header-nav"
      end

      scenario "サイドメニューが表示されること" do
        # サイドメニューの外側の要素を取得
        outside_side_menu = find("body")

        # サイドメニューが表示されること
        within "div.side-menu" do
          # サイドメニューリストが表示されていないこと
          expect(page).to have_no_checked_field "side-menu-toggle"
          expect(page).to have_no_selector "div.side-menu-list"

          # チェックボックスをチェックしてサイドメニューリストを表示する
          side_menu_label = find("label[for=side-menu-toggle]")
          side_menu_label.click

          # サイドメニューリストが表示されること
          within "div.side-menu-list" do
            # サイドメニューの検索フォームが表示されること
            within "li.side-menu-nav" do
              expect(page).to have_field "keyword"
              expect(page).to have_button
            end

            # トップページへのリンクが表示されること
            expect(page).to have_link nil, href: root_path

            # ルートカテゴリーへのリンクが表示されること
            root_categories.each do |root_category|
              expect(page).to have_link root_category.title,
                                        href: category_path(root_category)
            end
          end

          # サイドメニューの外側の要素をクリックする
          outside_side_menu.click

          # サイドメニューリストが非表示になること
          expect(page).to have_no_checked_field "side-menu-toggle"
          expect(page).to have_no_selector "div.side-menu-list"
        end
      end

      scenario "メニューバーが表示されないこと" do
        # メニューバーが表示されないこと
        expect(page).to have_no_selector "div.menu-bar"
      end
    end
  end

  feature "フッターのレイアウト" do
    scenario "プロフィールへのリンクが表示されること" do
      visit root_path

      within "div.footer-menu" do
        expect(page).to have_link "プロフィール", href: profile_path
      end
    end

    context "ログアウト時" do
      background do
        visit root_path
      end

      scenario "ログインへのリンクが表示されること" do
        within "div.footer-menu" do
          expect(page).to have_link "ログイン", href: new_user_session_path
        end
      end

      scenario "ログアウトへのリンクが表示されないこと" do
        # ログアウトへのリンクが表示されないこと
        within "div.footer-menu" do
          expect(page).to have_no_link "ログアウト", href: destroy_user_session_path
        end
      end

      scenario "画像一覧へのリンクが表示されないこと" do
        # 画像一覧へのリンクが表示されないこと
        within "div.footer-menu" do
          expect(page).to have_no_link "画像一覧", href: attachments_path
        end
      end
    end

    context "ログイン時" do
      given!(:user) { create(:user) }

      background do
        sign_in user
        visit root_path
      end

      scenario "ログインへのリンクが表示されないこと" do
        # ログインへのリンクが表示されないこと
        within "div.footer-menu" do
          expect(page).to have_no_link "ログイン", href: new_user_session_path
        end
      end

      scenario "ログアウトへのリンクが表示されること" do
        within "div.footer-menu" do
          expect(page).to have_link "ログアウト", href: destroy_user_session_path
        end
      end

      scenario "画像一覧へのリンクが表示されること" do
        within "div.footer-menu" do
          expect(page).to have_link "画像一覧", href: attachments_path
        end
      end
    end
  end
end
