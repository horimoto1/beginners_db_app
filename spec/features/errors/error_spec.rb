require "rails_helper"

RSpec.feature "Errors::Errors", type: :feature do
  feature "404エラーページのレイアウト" do
    scenario "見出し、画像が表示されること" do
      visit "/undefined"

      # 見出しが表示されること
      within "div.heading" do
        expect(page).to have_selector "h1", text: "404 Not Found"
      end

      # 画像が表示されること
      within "div.content" do
        expect(find("img")[:src]).to match /^\/assets\/404.*\.png$/
      end
    end
  end

  feature "500エラーページのレイアウト" do
    given!(:category) { create(:category) }

    background do
      # モックでStandardErrorを発生させるようにする
      allow_any_instance_of(CategoriesController).to \
        receive(:show).and_raise(StandardError)
    end

    scenario "見出し、画像が表示されること" do
      visit category_path(category)

      # 見出しが表示されること
      within "div.heading" do
        expect(page).to have_selector "h1", text: "500 Server Error"
      end

      # 画像が表示されること
      within "div.content" do
        expect(find("img")[:src]).to match /^\/assets\/500.*\.png$/
      end
    end
  end

  feature "非公開ページのレイアウト" do
    given!(:article) { create(:article) }

    scenario "見出しが表示されること" do
      visit category_article_path(article.category, article)

      # 見出しが表示されること
      within "div.heading" do
        expect(page).to have_selector "h1", text: "非公開"
      end
    end
  end
end