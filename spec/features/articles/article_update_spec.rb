require "rails_helper"

RSpec.feature "Articles::ArticleUpdates", type: :feature do
  given!(:user) { create(:user) }
  given!(:article) {
    create(:article, published: true,
                     image: "kitten.jpg",
                     content_type: "image/jpeg")
  }

  background do
    sign_in user
  end

  feature "記事編集ページのレイアウト" do
    scenario "タイトルが正しいこと" do
      visit edit_category_article_path(article.category, article)

      expect(page).to have_title "記事編集 | DB入門"
    end

    scenario "入力項目一覧が表示され、初期値が入力されていること" do
      visit category_article_path(article.category, article)

      find("label[for=edit-menu-toggle]").click
      click_on "記事を編集する"

      expect(page).to have_current_path edit_category_article_path(article.category,
                                                                   article), ignore_query: true

      expect(page).to have_field "スラッグ名", with: article.name

      expect(page).to have_field "タイトル", with: article.title

      # サムネイル
      input_file_text = find("#input-file-text")
      expect(input_file_text.value).to eq "kitten.jpg"
      expect(input_file_text.disabled?).to eq true

      expect(page).to have_field "サマリー", with: article.summary

      expect(page).to have_field "コンテンツ", with: article.content

      expect(page).to have_select "ステータス", options: ["非公開", "公開"],
                                           selected: "公開"

      expect(page).to have_field "記事の並び順", with: article.article_order

      expect(page).to have_field "カテゴリーID", with: article.category_id

      expect(page).to have_button "更新"
    end

    scenario "編集メニューが表示されること" do
      visit edit_category_article_path(article.category, article)

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

  feature "記事更新機能" do
    background do
      visit edit_category_article_path(article.category, article)
    end

    context "入力値が無効な場合" do
      scenario "記事が更新されず、エラーが表示されること" do
        invalid_fields = [{ locator: "スラッグ名", value: "" },
                          { locator: "タイトル", value: "" },
                          { locator: "コンテンツ", value: "" },
                          { locator: "記事の並び順", value: "" },
                          { locator: "カテゴリーID", value: "-1" }]

        invalid_fields.each do |invalid_field|
          fill_in invalid_field[:locator], with: invalid_field[:value]
        end

        # ファイル選択フォームにファイルをアタッチする
        file_path = Rails.root.join("spec/fixtures/5MB.png")
        attach_file("サムネイル", file_path, make_visible: true)

        # 記事が更新されないこと
        expect { click_on "更新" }.not_to change { article.reload.name }

        # エラーが表示されること
        expect(page).to have_selector "div.error_explanation"
        error_elements = all("div.field_with_errors")
        expect(error_elements.count).to eq(invalid_fields.count * 2 + 3)
      end
    end

    context "入力値が有効な場合" do
      given!(:category) { create(:category) }

      scenario "記事が更新され、フラッシュが表示されること" do
        valid_fields = [{ locator: "スラッグ名", value: "sample1" },
                        { locator: "タイトル", value: "サンプル1" },
                        { locator: "コンテンツ", value: "# サンプル1\n## サンプル2\n### サンプル3" },
                        { locator: "サマリー", value: "サンプル1" },
                        { locator: "記事の並び順", value: "10" },
                        { locator: "カテゴリーID", value: category.id }]

        valid_fields.each do |valid_field|
          fill_in valid_field[:locator], with: valid_field[:value]
        end

        # ファイル選択フォームにファイルをアタッチする
        file_path = Rails.root.join("spec/fixtures/rails.svg")
        attach_file("サムネイル", file_path, make_visible: true)

        select "非公開", from: "ステータス"

        # 記事が更新されること
        expect { click_on "更新" }.to change { article.reload.name }

        # 記事の詳細ページに遷移すること
        expect(page).to have_current_path category_article_path(category, article), ignore_query: true

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
