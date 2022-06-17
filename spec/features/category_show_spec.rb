require "rails_helper"

RSpec.feature "CategoryShows", type: :feature do
  given!(:root_categories) { create_list(:category, 3) }
  given!(:child_categories) {
    create_list(:category, 3,
                parent_category_id: root_categories[1].id)
  }
  given!(:root_category_articles) {
    create_list(:article, 3,
                category_id: root_categories[1].id,
                published: true)
  }
  given!(:child_category_articles) {
    create_list(:article, 3,
                category_id: child_categories[1].id,
                published: true)
  }

  feature "カテゴリー詳細ページのレイアウト" do
    background do
      visit category_path(root_categories[1])
    end

    scenario "パンくずリスト、作成日時、更新日時が表示されること" do
      # パンくずリストが表示されること
      within "div.breadcrumb" do
        expect(page).to have_link "ホーム", href: root_path
        expect(page).to have_link root_categories[1].title,
                                  href: category_path(root_categories[1])
      end

      # 作成日時、更新日時が表示されること
      within "div.info" do
        expect(page).to have_content root_categories[1].
                                       created_at.strftime("%Y/%m/%d")
        expect(page).to have_content root_categories[1].
                                       updated_at.strftime("%Y/%m/%d")
      end
    end

    # CSSアニメーションが含まれるためjsを有効にする
    scenario "見出し、目次、メニューが表示されること", driver: :selenium do
      # 見出しが表示されること
      within "div.heading" do
        expect(page).to have_selector "h1", text: root_categories[1].title
      end

      # 目次が表示されること
      within "div.toc" do
        # 目次のページ内リンク一覧が表示されること
        within "div.toc-table" do
          expect(page).to have_link root_categories[1].title,
                                    href: "##{root_categories[1].slug}"
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
          expect(page).to have_link root_categories[1].title,
                                    href: "##{root_categories[1].slug}"
          child_categories.each do |child_category|
            expect(page).to have_link child_category.title,
                                      href: "##{child_category.slug}"
          end
        end
      end

      # メニューが表示されること
      within "div.category-menu" do
        expect(page).to have_content root_categories[1].title

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
      within "div.pager-navi" do
        # 前のカテゴリーが表示されること
        within "div.previous" do
          expect(page).to have_link root_categories[0].title,
                                    href: category_path(root_categories[0])
        end

        # 次のカテゴリーが表示されること
        within "div.next" do
          expect(page).to have_link root_categories[2].title,
                                    href: category_path(root_categories[2])
        end
      end
    end

    context "ログアウト時" do
      given!(:root_category_private_articles) {
        create_list(:article, 3,
                    category_id: root_categories[1].id)
      }
      given!(:child_category_private_articles) {
        create_list(:article, 3,
                    category_id: child_categories[1].id)
      }

      background do
        visit category_path(root_categories[1])
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
                    category_id: root_categories[1].id)
      }
      given!(:child_category_private_articles) {
        create_list(:article, 3,
                    category_id: child_categories[1].id)
      }

      background do
        sign_in user
        visit category_path(root_categories[1])
      end

      scenario "アクションメニューが表示されること" do
        within "div.action-menu" do
          # カテゴリー作成ページへのリンクが表示されること
          expect(page).to have_link "カテゴリー作成",
                                    href: new_category_path(
                                      parent_category_id: root_categories[1].id,
                                    )

          # カテゴリー編集ページへのリンクが表示されること
          expect(page).to have_link "カテゴリー編集",
                                    href: edit_category_path(root_categories[1])

          # 記事投稿ページへのリンクが表示されること
          expect(page).to have_link "記事投稿",
                                    href: new_category_article_path(
                                      root_categories[1]
                                    )

          # カテゴリー削除ページへのリンクが表示されること
          expect(page).to have_link "カテゴリー削除",
                                    href: category_path(root_categories[1])
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
