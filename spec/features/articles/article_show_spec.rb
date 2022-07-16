require "rails_helper"

RSpec.feature "Articles::ArticleShows", type: :feature do
  given!(:category) { create(:category) }
  given!(:articles) {
    create_list(:article, 3,
                category_id: category.id,
                published: true)
  }
  given!(:article) { articles[1] }

  feature "記事詳細ページのレイアウト" do
    background do
      visit category_article_path(article.category, article)
    end

    scenario "パンくずリストが表示されること" do
      within "div.breadcrumb" do
        expect(page).to have_link "ホーム", href: root_path
        expect(page).to have_link article.category.title,
                                  href: category_path(article.category)
      end
    end

    scenario "作成日時、更新日時が表示されること" do
      within "div.meta" do
        expect(page).to have_content article.created_at.strftime("%Y/%m/%d")
        expect(page).to have_content article.updated_at.strftime("%Y/%m/%d")
      end
    end

    scenario "見出しが表示されること" do
      within "div.heading" do
        expect(page).to have_selector "h1", text: article.title
      end
    end

    scenario "目次が表示されること", js: true do
      within "div.toc" do
        # 目次のページ内リンク一覧が表示されること
        within "div.toc-table" do
          expect(page).to have_link "テスト1", href: "#toc_0"
          expect(page).to have_link "テスト2", href: "#toc_1"
          expect(page).to have_link "テスト3", href: "#toc_2"
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
          expect(page).to have_link "テスト1", href: "#toc_0"
          expect(page).to have_link "テスト2", href: "#toc_1"
          expect(page).to have_link "テスト3", href: "#toc_2"
        end
      end
    end

    scenario "コンテンツが表示されること" do
      within "div.content" do
        # マークダウンのパース結果が表示されること
        expect(page).to have_selector "h1#toc_0", text: "テスト1"
        expect(page).to have_selector "h2#toc_1", text: "テスト2"
        expect(page).to have_selector "h3#toc_2", text: "テスト3"
      end
    end

    scenario "ページャが表示されること" do
      within "div.pager" do
        # 前の記事へのリンクが表示されること
        within "div.previous" do
          expect(page).to have_link articles[0].title,
                                    href: category_article_path(
                                      articles[0].category, articles[0]
                                    )
        end

        # 次の記事へのリンクが表示されること
        within "div.next" do
          expect(page).to have_link articles[2].title,
                                    href: category_article_path(
                                      articles[2].category, articles[2]
                                    )
        end
      end
    end

    context "ログアウト時" do
      background do
        visit category_article_path(article.category, article)
      end

      scenario "ステータスが表示されないこと" do
        within "div.meta" do
          expect(page).to have_no_selector "div.status"
        end
      end

      scenario "編集メニューが表示されないこと" do
        expect(page).to have_no_selector "label[for=edit-menu-toggle]"
      end
    end

    context "ログイン時" do
      given!(:user) { create(:user) }
      given!(:private_article) { create(:article) }

      background do
        sign_in user
      end

      context "記事が非公開" do
        scenario "ステータスが非公開で表示されること" do
          visit category_article_path(private_article.category, private_article)

          within "div.meta" do
            expect(page).to have_content "非公開"
          end
        end
      end

      context "記事が公開中" do
        scenario "ステータスが公開中で表示されること" do
          visit category_article_path(article.category, article)

          within "div.meta" do
            expect(page).to have_content "公開中"
          end
        end
      end

      scenario "編集メニューが表示されること" do
        visit category_article_path(article.category, article)

        find("label[for=edit-menu-toggle]").click
        within "div.edit-menu" do
          # 記事編集ページへのリンクが表示されること
          expect(page).to have_link "記事を編集する",
                                    href: edit_category_article_path(
                                      article.category, article
                                    )

          # 記事削除機能へのリンクが表示されること
          expect(page).to have_link "記事を削除する",
                                    href: category_article_path(
                                      article.category, article
                                    )
        end
      end
    end
  end
end
