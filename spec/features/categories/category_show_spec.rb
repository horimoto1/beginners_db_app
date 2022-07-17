require "rails_helper"

RSpec.feature "Categories::CategoryShows", type: :feature do
  given!(:root_categories) { create_list(:category, 3) }
  given!(:root_category) { root_categories[1] }
  given!(:child_categories) {
    create_list(:category, 3,
                parent_category_id: root_category.id)
  }
  given!(:child_category) { child_categories[1] }
  given!(:root_category_articles) {
    create_list(:article, 3,
                category_id: root_category.id,
                published: true)
  }
  given!(:child_category_articles) {
    create_list(:article, 3,
                category_id: child_category.id,
                published: true)
  }

  feature "カテゴリー詳細ページのレイアウト" do
    scenario "タイトルが正しいこと" do
      visit category_path(root_category)

      expect(page).to have_title "#{root_category.title} | DB入門"
    end

    scenario "パンくずリストが表示されること" do
      visit category_path(root_category)

      # パンくずリストが表示されること
      within "div.breadcrumb" do
        expect(page).to have_link "ホーム", href: root_path
        expect(page).to have_link root_category.title,
                                  href: category_path(root_category)
      end
    end

    scenario "作成日時、更新日時が表示されること" do
      visit category_path(root_category)

      # 作成日時、更新日時が表示されること
      within "div.meta" do
        expect(page).to have_content root_category.created_at.strftime("%Y/%m/%d")
        expect(page).to have_content root_category.updated_at.strftime("%Y/%m/%d")
      end
    end

    scenario "見出しが表示されること" do
      visit category_path(root_category)

      # 見出しが表示されること
      within "div.heading" do
        expect(page).to have_selector "h1", text: root_category.title
      end
    end

    scenario "目次が表示されること", js: true do
      visit category_path(root_category)

      # 目次が表示されること
      within "div.toc" do
        # 目次のページ内リンク一覧が表示されること
        within "div.toc-table" do
          expect(page).to have_link root_category.title,
                                    href: "##{root_category.slug}"
          expect(page).to have_link child_category.title,
                                    href: "##{child_category.slug}"
        end

        # 目次を閉じる
        toc_label = find("label[for=toc-toggle]")
        toc_label.click

        # 目次のページ内リンク一覧が非表示になること
        expect(page).to have_no_selector "div.toc-table"

        # 目次を開く
        toc_label.click

        # 目次のページ内リンク一覧が再表示されること
        within "div.toc-table" do
          expect(page).to have_link root_category.title,
                                    href: "##{root_category.slug}"
          expect(page).to have_link child_category.title,
                                    href: "##{child_category.slug}"
        end
      end
    end

    scenario "メニューが表示されること" do
      visit category_path(root_category)

      # メニューが表示されること
      within "div.category-menu" do
        expect(page).to have_content root_category.title

        # 記事一覧が表示されること
        root_category_articles.each do |root_category_article|
          expect(page).to have_link root_category_article.title,
                                    href: category_article_path(
                                      root_category_article.category,
                                      root_category_article
                                    )
        end

        # 子カテゴリーが表示されること
        expect(page).to have_link child_category.title,
                                  href: category_path(child_category)

        # 子カテゴリーの記事一覧が表示されること
        child_category_articles.each do |child_category_article|
          expect(page).to have_link child_category_article.title,
                                    href: category_article_path(
                                      child_category_article.category,
                                      child_category_article
                                    )
        end
      end
    end

    context "ログアウト時" do
      given!(:root_category_private_articles) {
        create_list(:article, 3,
                    category_id: root_category.id)
      }
      given!(:child_category_private_articles) {
        create_list(:article, 3,
                    category_id: child_category.id)
      }

      background do
        create_list(:article, 3,
                    category_id: root_categories[0].id)

        create_list(:article, 3,
                    category_id: child_categories[0].id)

        visit category_path(root_category)
      end

      scenario "編集メニューが表示されないこと" do
        expect(page).to have_no_selector "label[for=edit-menu-toggle]"
      end

      scenario "非公開記事のみのカテゴリーがメニューに表示されないこと" do
        within "div.category-menu" do
          expect(page).to have_no_link child_categories[0].title,
                                       href: category_path(child_categories[0])
        end
      end

      scenario "記事が1つも無いカテゴリーがメニューに表示されないこと" do
        within "div.category-menu" do
          expect(page).to have_no_link child_categories[2].title,
                                       href: category_path(child_categories[2])
        end
      end

      scenario "非公開の記事がメニューに表示されないこと" do
        within "div.category-menu" do
          # ルートカテゴリーの非公開記事一覧が表示されないこと
          root_category_private_articles.each do |root_category_private_article|
            expect(page).to have_no_link root_category_private_article.title,
                                         href: category_article_path(
                                           root_category_private_article.category,
                                           root_category_private_article
                                         )
          end

          # 子カテゴリーの非公開記事一覧が表示されないこと
          child_category_private_articles.each do |child_category_private_article|
            expect(page).to have_no_link child_category_private_article.title,
                                         href: category_article_path(
                                           child_category_private_article.category,
                                           child_category_private_article
                                         )
          end
        end
      end

      scenario "非公開記事のみのカテゴリーのページャが表示されないこと" do
        within "div.pager" do
          expect(page).to have_no_link root_categories[0].title,
                                       href: category_path(root_categories[0])
        end
      end

      scenario "記事が1つも無いカテゴリーのページャが表示されないこと" do
        within "div.pager" do
          expect(page).to have_no_link root_categories[2].title,
                                       href: category_path(root_categories[2])
        end
      end
    end

    context "ログイン時" do
      given!(:user) { create(:user) }
      given!(:root_category_private_articles) {
        create_list(:article, 3,
                    category_id: root_category.id)
      }
      given!(:child_category_private_articles) {
        create_list(:article, 3,
                    category_id: child_category.id)
      }

      background do
        create_list(:article, 3,
                    category_id: root_categories[0].id)

        create_list(:article, 3,
                    category_id: child_categories[0].id)

        sign_in user
        visit category_path(root_category)
      end

      scenario "編集メニューが表示されること" do
        find("label[for=edit-menu-toggle]").click
        within "div.edit-menu" do
          # カテゴリー作成ページへのリンクが表示されること
          expect(page).to have_link "カテゴリーを作成する",
                                    href: new_category_path(
                                      parent_category_id: root_category.id
                                    )

          # カテゴリー編集ページへのリンクが表示されること
          expect(page).to have_link "カテゴリーを編集する",
                                    href: edit_category_path(root_category)

          # 記事投稿ページへのリンクが表示されること
          expect(page).to have_link "記事を投稿する",
                                    href: new_category_article_path(
                                      root_category
                                    )

          # カテゴリー削除機能へのリンクが表示されること
          expect(page).to have_link "カテゴリーを削除する",
                                    href: category_path(root_category)
        end
      end

      scenario "非公開記事のみのカテゴリーがメニューに表示されること" do
        within "div.category-menu" do
          expect(page).to have_link child_categories[0].title,
                                    href: category_path(child_categories[0])
        end
      end

      scenario "記事が1つも無いカテゴリーがメニューに表示されること" do
        within "div.category-menu" do
          expect(page).to have_link child_categories[2].title,
                                    href: category_path(child_categories[2])
        end
      end

      scenario "非公開の記事がメニューに表示されること" do
        within "div.category-menu" do
          # ルートカテゴリーの非公開記事一覧が表示されること
          root_category_private_articles.each do |root_category_private_article|
            expect(page).to have_link root_category_private_article.title,
                                      href: category_article_path(
                                        root_category_private_article.category,
                                        root_category_private_article
                                      )
          end

          # 子カテゴリーの非公開記事一覧が表示されること
          child_category_private_articles.each do |child_category_private_article|
            expect(page).to have_link child_category_private_article.title,
                                      href: category_article_path(
                                        child_category_private_article.category,
                                        child_category_private_article
                                      )
          end
        end
      end

      scenario "非公開記事のみのカテゴリーのページャが表示されること" do
        within "div.pager" do
          # 前のカテゴリーへのリンクが表示されること
          within "div.previous" do
            expect(page).to have_link root_categories[0].title,
                                      href: category_path(root_categories[0])
          end
        end
      end

      scenario "記事が1つも無いカテゴリーのページャが表示されること" do
        within "div.pager" do
          # 次のカテゴリーへのリンクが表示されること
          within "div.next" do
            expect(page).to have_link root_categories[2].title,
                                      href: category_path(root_categories[2])
          end
        end
      end
    end
  end
end
