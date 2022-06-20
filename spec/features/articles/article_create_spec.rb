require "rails_helper"

RSpec.feature "Articles::ArticleCreates", type: :feature do
  given!(:user) { create(:user) }
  given!(:category) { create(:category) }

  background do
    sign_in user
  end

  feature "記事投稿ページのレイアウト" do
    scenario "入力項目一覧が表示され、初期値が入力されていること" do
      visit category_path(category)

      click_on "記事投稿"

      expect(page.current_path).to eq new_category_article_path(category)

      expect(find_field("スラッグ名").text).to be_blank

      expect(find_field("タイトル").text).to be_blank

      expect(find_field("サマリー").text).to be_blank

      expect(find_field("コンテンツ").text).to be_blank

      expect(page).to have_select "ステータス", options: ["非公開", "公開"],
                                           selected: "非公開"

      expect(page).to have_field "記事の並び順", with: category.articles.count + 1

      expect(page).to have_field "カテゴリーID", with: category.id

      expect(page).to have_button "投稿"
    end
  end

  feature "記事投稿機能" do
    background do
      visit new_category_article_path(category)
    end

    context "入力値が無効な場合" do
      scenario "記事が作成されず、エラーが表示されること" do
        invalid_fields = [{ locator: "スラッグ名", value: "" },
                          { locator: "タイトル", value: "" },
                          { locator: "コンテンツ", value: "" },
                          { locator: "記事の並び順", value: "" },
                          { locator: "カテゴリーID", value: "-1" }]

        invalid_fields.each do |invalid_field|
          fill_in invalid_field[:locator], with: invalid_field[:value]
        end

        # カテゴリーが作成されないこと
        expect { click_on "投稿" }.not_to change { Article.count }

        # エラーが表示されること
        expect(page).to have_selector "div.error_explanation"
        error_elements = all("div.field_with_errors")
        expect(error_elements.count).to eq (invalid_fields.count * 2)
      end
    end

    context "入力値が有効な場合" do
      scenario "記事が作成され、フラッシュが表示されること" do
        valid_fields = [{ locator: "スラッグ名", value: "sample1" },
                        { locator: "タイトル", value: "サンプル1" },
                        { locator: "コンテンツ", value: "# サンプル1\n## サンプル2\n### サンプル3" },
                        { locator: "サマリー", value: "サンプル1" },
                        { locator: "記事の並び順", value: "1" },
                        { locator: "カテゴリーID", value: category.id }]

        valid_fields.each do |valid_field|
          fill_in valid_field[:locator], with: valid_field[:value]
        end

        select "公開", from: "ステータス"

        # 記事が作成されること
        expect { click_on "投稿" }.to change { Article.count }.by(1)

        # 記事の詳細ページに遷移すること
        expect(page.current_path).to eq category_article_path(category, Article.last)

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
