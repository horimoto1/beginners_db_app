require "rails_helper"

RSpec.feature "SiteLayouts", type: :feature, js: true do
  feature "ヘッダー" do
    given!(:root_categories) { create_list(:category, 4) }

    background do
      visit root_path
    end

    context "画面幅が800pxより大きい場合" do
      background do
        width = 1000 # 801pxだとパスしないため1000pxに調整
        height = 800
        current_window.resize_to(width, height)
      end

      scenario "ロゴ、検索フォーム、メニューバーが表示されること" do
        # ロゴが表示されること
        within "div.header-logo" do
          # TOPへのリンクが表示されること
          expect(page).to have_link nil, href: root_path
        end

        # ヘッダーの検索フォームが表示されること
        within "div.header-nav" do
          expect(page).to have_field "keyword"
          expect(page).to have_button
        end

        # サイドメニューが表示されないこと
        expect(page).to have_no_selector "div.side-menu"

        # メニューバーが表示されること
        within "div.menu-bar" do
          # TOPへのリンクが表示されること
          expect(page).to have_link nil, href: root_path

          # ルートカテゴリーへのリンクが表示されること
          root_categories.each do |root_category|
            expect(page).to have_link root_category.title,
                                      href: category_path(root_category)
          end
        end
      end
    end

    context "画面幅が800px以下の場合" do
      background do
        width = 800
        height = 800
        current_window.resize_to(width, height)
      end

      scenario "ロゴ、サイドメニューが表示されること" do
        # ロゴが表示されること
        within "div.header-logo" do
          # TOPへのリンクが表示されること
          expect(page).to have_link nil, href: root_path
        end

        # ヘッダーの検索フォームが表示されないこと
        expect(page).to have_no_selector "div.header-nav"

        # サイドメニューが表示されること
        within "div.side-menu" do
          # 初期状態はサイドメニューリストが表示されないこと
          expect(page).to have_no_checked_field "side-menu-toggle"
          expect(page).to have_no_selector "div.side-menu-list"

          # チェックボックスをクリックしてサイドメニューリストを表示する
          label = find("label[for=side-menu-toggle]")
          label.click

          # サイドメニューリストが表示されること
          within "div.side-menu-list" do
            # サイドメニューの検索フォームが表示されること
            within "li.side-menu-nav" do
              expect(page).to have_field "keyword"
              expect(page).to have_button
            end

            # TOPへのリンクが表示されること
            expect(page).to have_link nil, href: root_path

            # ルートカテゴリーへのリンクが表示されること
            root_categories.each do |root_category|
              expect(page).to have_link root_category.title,
                                        href: category_path(root_category)
            end
          end
        end

        # メニューバーが表示されないこと
        expect(page).to have_no_selector "div.menu-bar"
      end
    end
  end

  feature "フッター" do
    given!(:user) { create(:user) }

    context "ログアウト時" do
      scenario "プロフィール、ログインへのリンクが表示されること" do
        visit root_path

        within "div.footer-menu" do
          expect(page).to have_link "ログイン", href: new_user_session_path
          expect(page).to have_link "プロフィール", href: profile_path

          # ログアウトへのリンクが表示されないこと
          expect(page).to have_no_link "ログアウト", href: destroy_user_session_path
        end
      end
    end

    context "ログイン時" do
      scenario "プロフィール、ログアウトへのリンクが表示されること" do
        sign_in user
        visit root_path

        within "div.footer-menu" do
          expect(page).to have_link "ログアウト", href: destroy_user_session_path
          expect(page).to have_link "プロフィール", href: profile_path

          # ログインへのリンクが表示されないこと
          expect(page).to have_no_link "ログイン", href: new_user_session_path
        end
      end
    end
  end
end
