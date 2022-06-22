require "rails_helper"

RSpec.feature "Searches::Searches", type: :feature do
  feature "検索結果ページのレイアウト" do
    given!(:category) { create(:category) }
    given!(:published_articles) {
      create_list(:article, 20,
                  category_id: category.id, published: true)
    }
    given!(:private_articles) {
      create_list(:article, 20,
                  category_id: category.id)
    }

    background do
      visit root_path
    end

    context "キーワードがヒットしなかった場合" do
      scenario "見出しが表示されること" do
        keyword = "no hit keyword"

        # 検索する
        within "div.header-nav" do
          fill_in "keyword", with: keyword
          click_button
          expect(page.current_path).to eq searches_path
        end

        # 見出しが表示されること
        within "div.heading" do
          expect(page).to have_selector "h1", text: "検索結果"
          expect(page).to have_content keyword
          expect(page).to have_content "キーワードが見つかりませんでした。"
        end

        # 検索結果が表示されていないこと
        expect(page).to have_no_selector "div.search-result"

        # ページネーションが表示されていないこと
        expect(page).to have_no_selector "nav.pagination"
      end
    end

    context "キーワードがヒットした場合" do
      context "ログアウト時" do
        scenario "見出し、検索結果、ページネーションが表示され、非公開記事が検索結果に含まれないこと" do
          keyword = "test"

          # 検索する
          within "div.header-nav" do
            fill_in "keyword", with: keyword
            click_button
            expect(page.current_path).to eq searches_path
          end

          # 見出しが表示されること
          within "div.heading" do
            expect(page).to have_selector "h1", text: "検索結果"
            expect(page).to have_content keyword
            # 公開済みの記事の件数のみ表示されること
            expect(page).to have_content "20件中の1～10件目を表示しています。"
          end

          # 検索結果が表示されること
          within "div.search-result" do
            # 1ページ目に公開している記事が更新順で10件表示されること
            Article.published.order(updated_at: :desc).limit(10)
              .each do |article|
              expect(page).to have_link article.title,
                                        href: category_article_path(
                                          article.category, article
                                        )
            end
          end

          # ページネーションが表示されること
          within "nav.pagination" do
            # 2ページ目のリンクが表示されること
            expect(page).to have_link "2", href: searches_path(
                             keyword: keyword, page: 2,
                           )

            # 3～4ページ目のリンクが表示されないこと
            (3..4).each do |n|
              expect(page).to have_no_link n.to_s
            end
          end
        end
      end

      context "ログイン時" do
        given!(:user) { create(:user) }

        background do
          sign_in user
        end

        scenario "見出し、検索結果、ページネーションが表示され、非公開記事が検索結果に含まれること" do
          keyword = "test"

          # 検索する
          within "div.header-nav" do
            fill_in "keyword", with: keyword
            click_button
            expect(page.current_path).to eq searches_path
          end

          # 見出しが表示されること
          within "div.heading" do
            expect(page).to have_selector "h1", text: "検索結果"
            expect(page).to have_content keyword
            # 非公開の記事の件数も含まれること
            expect(page).to have_content "40件中の1～10件目を表示しています。"
          end

          # 検索結果が表示されること
          within "div.search-result" do
            # 1ページ目に非公開の記事が更新順で10件表示されること
            Article.where(status: "private").order(updated_at: :desc).limit(10)
              .each do |article|
              expect(page).to have_link article.title,
                                        href: category_article_path(
                                          article.category, article
                                        )
            end
          end

          # ページネーションが表示されること
          within "nav.pagination" do
            # 2～4ページ目のリンクが表示されること
            (2..4).each do |n|
              expect(page).to have_link n.to_s,
                                        href: searches_path(
                                          keyword: keyword, page: n,
                                        )
            end
          end
        end
      end
    end

    context "キーワードがスペースだけの場合", js: true do
      background do
        width = 1000
        height = 800
        current_window.resize_to(width, height)
      end

      scenario "検索できないこと" do
        within "div.header-nav" do
          # 空欄
          fill_in "keyword", with: ""
          click_button
          expect(page.current_path).not_to eq searches_path

          # 半角スペース
          fill_in "keyword", with: " "
          click_button
          expect(page.current_path).not_to eq searches_path

          # 全角スペース
          fill_in "keyword", with: "　"
          click_button
          expect(page.current_path).not_to eq searches_path
        end
      end
    end

    context "サイドメニューの検索フォームから検索する場合", js: true do
      background do
        width = 800
        height = 800
        current_window.resize_to(width, height)
      end

      scenario "検索できること" do
        # チェックボックスをチェックしてサイドメニューリストを表示する
        side_menu_label = find("label[for=side-menu-toggle]")
        side_menu_label.click

        within "li.side-menu-nav" do
          fill_in "keyword", with: "test"
          click_button
          expect(page.current_path).to eq searches_path
        end
      end
    end
  end
end
