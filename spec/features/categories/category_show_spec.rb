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
    scenario "パンくずリスト、作成日時、更新日時が表示されること" do
      visit category_path(root_category)

      # パンくずリストが表示されること
      within "div.breadcrumb" do
        expect(page).to have_link "ホーム", href: root_path
        expect(page).to have_link root_category.title,
                                  href: category_path(root_category)
      end

      # 作成日時、更新日時が表示されること
      within "div.meta" do
        expect(page).to have_content root_category.
                                       created_at.strftime("%Y/%m/%d")
        expect(page).to have_content root_category.
                                       updated_at.strftime("%Y/%m/%d")
      end
    end

    scenario "見出し、目次、メニューが表示されること", js: true do
      visit category_path(root_category)

      # 見出しが表示されること
      within "div.heading" do
        expect(page).to have_selector "h1", text: root_category.title
      end

      # 目次が表示されること
      within "div.toc" do
        # 目次のページ内リンク一覧が表示されること
        within "div.toc-table" do
          expect(page).to have_link root_category.title,
                                    href: "##{root_category.slug}"
          child_categories.each do |child_category|
            expect(page).to have_link child_category.title,
                                      href: "##{child_category.slug}"
          end
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
          child_categories.each do |child_category|
            expect(page).to have_link child_category.title,
                                      href: "##{child_category.slug}"
          end
        end
      end

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

        # 子カテゴリー一覧が表示されること
        child_categories.each do |child_category|
          expect(page).to have_link child_category.title,
                                    href: category_path(child_category)
        end

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

    scenario "ページャが表示されること" do
      visit category_path(root_category)

      within "div.pager" do
        # 前のカテゴリーへのリンクが表示されること
        within "div.previous" do
          expect(page).to have_link root_categories[0].title,
                                    href: category_path(root_categories[0])
        end

        # 次のカテゴリーへのリンクが表示されること
        within "div.next" do
          expect(page).to have_link root_categories[2].title,
                                    href: category_path(root_categories[2])
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
        visit category_path(root_category)
      end

      scenario "アクションメニューが表示されないこと" do
        expect(page).to have_no_selector "div.action-menu"
      end

      scenario "非公開の記事が表示されないこと" do
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
        sign_in user
        visit category_path(root_category)
      end

      scenario "アクションメニューが表示されること" do
        within "div.action-menu" do
          # カテゴリー作成ページへのリンクが表示されること
          expect(page).to have_link "カテゴリー作成",
                                    href: new_category_path(
                                      parent_category_id: root_category.id,
                                    )

          # カテゴリー編集ページへのリンクが表示されること
          expect(page).to have_link "カテゴリー編集",
                                    href: edit_category_path(root_category)

          # 記事投稿ページへのリンクが表示されること
          expect(page).to have_link "記事投稿",
                                    href: new_category_article_path(
                                      root_category
                                    )

          # カテゴリー削除機能へのリンクが表示されること
          expect(page).to have_link "カテゴリー削除",
                                    href: category_path(root_category)
        end
      end

      scenario "非公開の記事が表示されること" do
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
  end
end
