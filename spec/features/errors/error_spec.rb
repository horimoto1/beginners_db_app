require "rails_helper"

RSpec.feature "Errors::Errors", type: :feature do
  feature "404エラーページのレイアウト" do
    background do
      visit "/undefined"
    end

    scenario "タイトルが正しいこと" do
      expect(page).to have_title "404 Not Found | DB入門"
    end

    scenario "見出し、画像が表示されること" do
      within "div.heading" do
        expect(page).to have_selector "h1", text: "404 Not Found"
      end
    end

    scenario "画像が表示されること" do
      within "div.content" do
        expect(find("img")[:src]).to match(%r{^/assets/404.*\.svg$})
      end
    end
  end

  feature "500エラーページのレイアウト" do
    given!(:category) { create(:category) }

    background do
      create(:article,
             category_id: category.id,
             published: true)

      # モックでStandardErrorを発生させるようにする
      allow_any_instance_of(CategoriesController).to \
        receive(:show).and_raise(StandardError)

      visit category_path(category)
    end

    scenario "タイトルが正しいこと" do
      expect(page).to have_title "500 Server Error | DB入門"
    end

    scenario "見出しが表示されること" do
      within "div.heading" do
        expect(page).to have_selector "h1", text: "500 Server Error"
      end
    end

    scenario "画像が表示されること" do
      within "div.content" do
        expect(find("img")[:src]).to match(%r{^/assets/500.*\.svg$})
      end
    end
  end

  feature "非公開ページのレイアウト" do
    given!(:article) { create(:article) }

    background do
      visit category_article_path(article.category, article)
    end

    scenario "タイトルが正しいこと" do
      expect(page).to have_title "非公開 | DB入門"
    end

    scenario "見出しが表示されること" do
      within "div.heading" do
        expect(page).to have_selector "h1", text: "非公開"
      end
    end

    scenario "画像が表示されること" do
      within "div.content" do
        expect(find("img")[:src]).to match(%r{^/assets/not_published.*\.svg$})
      end
    end
  end
end
