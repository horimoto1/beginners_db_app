require "rails_helper"

RSpec.feature "Home::HomeTops", type: :feature do
  feature "トップページのレイアウト" do
    given!(:root_categories) { create_list(:category, 3) }
    given!(:published_articles) {
      create_list(:article, 10, category_id: root_categories.first.id,
                                published: true)
    }
    given!(:private_articles) {
      create_list(:article, 10, category_id: root_categories.first.id)
    }

    scenario "タイトルが正しいこと" do
      visit root_path

      expect(page).to have_title "DB入門"
    end

    scenario "見出しが表示されること" do
      visit root_path

      within "div.heading" do
        expect(page).to have_selector "h1", text: "TOP PAGE"
      end
    end

    scenario "メニューが表示されること" do
      visit root_path

      within "div.top-menu" do
        # ルートカテゴリーへのリンクが表示されること
        root_categories.each do |root_category|
          expect(page).to have_link root_category.title,
                                    href: category_path(root_category)
        end
      end
    end

    context "ログアウト時" do
      background do
        visit root_path
      end

      scenario "編集メニューが表示されないこと" do
        expect(page).to have_no_selector "label[for=edit-menu-toggle]"
      end

      scenario "最新情報が表示され、非公開記事が含まれないこと" do
        within "div.latest-updates" do
          # 1ページ目に公開している記事が更新順で5件表示されること
          Article.published.order(updated_at: :desc).limit(5)
                 .each do |article|
            expect(page).to have_link article.title,
                                      href: category_article_path(
                                        article.category, article
                                      )
          end
        end
      end

      scenario "ページネーションが表示され、非公開記事の数が含まれないこと" do
        within "nav.pagination" do
          # 2ページ目のリンクが表示されること
          expect(page).to have_link "2",
                                    href: root_path(
                                      page: 2, anchor: "latest-updates"
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
        visit root_path
      end

      scenario "編集メニューが表示されること" do
        find("label[for=edit-menu-toggle]").click
        within "div.edit-menu" do
          # カテゴリー作成ページへのリンクが表示されること
          expect(page).to have_link "カテゴリーを作成する", href: new_category_path
        end
      end

      scenario "最新情報が表示され、非公開記事が含まれること" do
        within "div.latest-updates" do
          # 1ページ目に非公開の記事が更新順で5件表示されること
          Article.where(status: "private").order(updated_at: :desc).limit(5)
                 .each do |article|
            expect(page).to have_link article.title,
                                      href: category_article_path(
                                        article.category, article
                                      )
          end
        end
      end

      scenario "ページネーションが表示され、非公開記事の数が含まれること" do
        within "nav.pagination" do
          # 2～4ページ目のリンクが表示されること
          (2..4).each do |n|
            expect(page).to have_link n.to_s,
                                      href: root_path(
                                        page: n, anchor: "latest-updates"
                                      )
          end
        end
      end
    end
  end
end
