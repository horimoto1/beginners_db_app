require "rails_helper"

RSpec.feature "Searches::Searches", type: :feature do
  feature "検索結果ページのレイアウト" do
    given!(:category) { create(:category) }
    given!(:published_articles) {
      create_list(:article, 20, category_id: category.id, published: true)
    }
    given!(:private_articles) {
      create_list(:article, 20, category_id: category.id)
    }

    scenario "見出しが表示されること" do
      visit searches_path

      # 見出しが表示されること
      within "div.heading" do
        expect(page).to have_selector "h1", text: "検索結果"
      end
    end

    scenario "キーワードが検索フォームに保持されること" do
      keyword = "test"
      visit root_path

      # 検索する
      within "div.header-nav" do
        fill_in "keyword", with: keyword
        click_button
        expect(page).to have_current_path searches_path, ignore_query: true

        # キーワードが検索フォームに保持されること
        expect(page).to have_field "keyword", with: keyword
      end
    end

    context "キーワードがヒットしなかった場合" do
      background do
        visit searches_path(keyword: "no hit keyword")
      end

      scenario "検索結果が表示されていないこと" do
        # 検索結果が表示されていないこと
        expect(page).to have_no_selector "div.search-result"
      end

      scenario "ページネーションが表示されていないこと" do
        # ページネーションが表示されていないこと
        expect(page).to have_no_selector "nav.pagination"
      end
    end

    context "キーワードがヒットした場合" do
      given!(:keyword) { "test" }

      context "ログアウト時" do
        background do
          visit searches_path(keyword: keyword)
        end

        scenario "検索結果が表示され、非公開記事が含まれないこと" do
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
        end

        scenario "ページネーションが表示され、非公開記事の数が含まれないこと" do
          # ページネーションが表示されること
          within "nav.pagination" do
            # 2ページ目のリンクが表示されること
            expect(page).to have_link "2",
                                      href: searches_path(
                                        keyword: keyword, page: 2
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
          visit searches_path(keyword: keyword)
        end

        scenario "検索結果が表示され、非公開記事が含まれること" do
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
        end

        scenario "ページネーションが表示され、非公開記事の数が含まれること" do
          # ページネーションが表示されること
          within "nav.pagination" do
            # 2～4ページ目のリンクが表示されること
            (2..4).each do |n|
              expect(page).to have_link n.to_s,
                                        href: searches_path(
                                          keyword: keyword, page: n
                                        )
            end
          end
        end
      end
    end

    context "複数のキーワードをスペース区切りで指定した場合" do
      given!(:keyword) { "サンプル1 サンプル2 サンプル3" }
      given!(:sample_articles) {
        create_list(:article, 10, category_id: category.id, published: true,
                                  summary: "テスト サンプル1 サンプル2 サンプル3")
      }

      background do
        visit searches_path(keyword: keyword)
      end

      scenario "AND検索ができること" do
        # 検索結果が表示されること
        within "div.search-result" do
          sample_articles.each do |article|
            expect(page).to have_link article.title,
                                      href: category_article_path(
                                        article.category, article
                                      )
          end
        end
      end

      scenario "複数のキーワードが検索フォームに保持されること" do
        within "div.header-nav" do
          # キーワードが検索フォームに保持されること
          expect(page).to have_field "keyword", with: keyword
        end
      end
    end

    context "キーワードがスペースだけの場合", js: true do
      background do
        visit root_path
        width = 1000
        height = 800
        current_window.resize_to(width, height)
      end

      scenario "検索できないこと" do
        within "div.header-nav" do
          # 空欄
          fill_in "keyword", with: ""
          click_button
          expect(page).to have_no_current_path searches_path, ignore_query: true

          # 半角スペース
          fill_in "keyword", with: " "
          click_button
          expect(page).to have_no_current_path searches_path, ignore_query: true

          # 全角スペース
          fill_in "keyword", with: "　"
          click_button
          expect(page).to have_no_current_path searches_path, ignore_query: true
        end
      end
    end

    context "サイドメニューの検索フォームから検索する場合", js: true do
      background do
        visit root_path
        width = 800
        height = 800
        current_window.resize_to(width, height)
      end

      scenario "キーワードがサイドメニューの検索フォームに保持されること" do
        keyword = "test"

        # チェックボックスをチェックしてサイドメニューリストを表示する
        side_menu_label = find("label[for=side-menu-toggle]")
        side_menu_label.click

        within "li.side-menu-nav" do
          fill_in "keyword", with: keyword
          click_button
          expect(page).to have_current_path searches_path, ignore_query: true
        end

        # ページ遷移するのでもう一度サイドメニューリストを表示する
        side_menu_label = find("label[for=side-menu-toggle]")
        side_menu_label.click

        within "li.side-menu-nav" do
          # キーワードが検索フォームに保持されること
          expect(page).to have_field "keyword", with: keyword
        end
      end
    end
  end
end
