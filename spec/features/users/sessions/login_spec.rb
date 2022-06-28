require 'rails_helper'

RSpec.feature 'Users::Sessions::Logins', type: :feature do
  given!(:user) { create(:user) }

  feature 'ログインページのレイアウト' do
    scenario '入力項目一覧が表示されること' do
      visit root_path

      within 'footer' do
        click_on 'ログイン'
      end

      expect(page).to have_current_path new_user_session_path, ignore_query: true

      expect(find_field('Eメール').text).to be_blank

      password = find_field('パスワード')
      expect(password.text).to be_blank
      # パスワードは伏字になっていること
      expect(password[:type]).to eq 'password'

      expect(page).to have_unchecked_field 'ログイン状態を保持する'

      within 'div.main' do
        expect(page).to have_button 'ログイン'
      end
    end
  end

  feature 'ログイン機能' do
    background do
      visit new_user_session_path
    end

    context '入力値が無効な場合' do
      context 'Eメールが無効な場合' do
        scenario 'ログインに失敗し、フラッシュが表示されること' do
          invalid_fields = [{ locator: 'Eメール', value: 'invalid@example.com' },
                            { locator: 'パスワード', value: user.password }]

          invalid_fields.each do |invalid_field|
            fill_in invalid_field[:locator], with: invalid_field[:value]
          end

          within 'div.main' do
            click_on 'ログイン'
          end

          # ログインに失敗すること
          expect(page).to have_current_path new_user_session_path, ignore_query: true
          within 'footer' do
            expect(page).to have_link 'ログイン', href: new_user_session_path
          end

          # フラッシュが表示されること
          within 'div.flash' do
            expect(page).to have_selector 'p.alert'
          end

          # リロードしたらフラッシュが消えること
          visit current_path
          expect(page).to have_no_selector 'div.flash'
        end
      end

      context 'パスワードが無効な場合' do
        scenario 'ログインに失敗し、フラッシュが表示されること' do
          invalid_fields = [{ locator: 'Eメール', value: user.email },
                            { locator: 'パスワード', value: 'invalid' }]

          invalid_fields.each do |invalid_field|
            fill_in invalid_field[:locator], with: invalid_field[:value]
          end

          within 'div.main' do
            click_on 'ログイン'
          end

          # ログインに失敗すること
          expect(page).to have_current_path new_user_session_path, ignore_query: true
          within 'footer' do
            expect(page).to have_link 'ログイン', href: new_user_session_path
          end

          # フラッシュが表示されること
          within 'div.flash' do
            expect(page).to have_selector 'p.alert'
          end

          # リロードしたらフラッシュが消えること
          visit current_path
          expect(page).to have_no_selector 'div.flash'
        end
      end
    end

    context '入力値が有効な場合' do
      scenario 'ログインに成功し、フラッシュが表示されること' do
        valid_fields = [{ locator: 'Eメール', value: user.email },
                        { locator: 'パスワード', value: user.password }]

        valid_fields.each do |valid_field|
          fill_in valid_field[:locator], with: valid_field[:value]
        end

        within 'div.main' do
          click_on 'ログイン'
        end

        # ログインに成功すること
        expect(page).to have_current_path root_path, ignore_query: true
        within 'footer' do
          expect(page).to have_link 'ログアウト', href: destroy_user_session_path
        end

        # フラッシュが表示されること
        within 'div.flash' do
          expect(page).to have_selector 'p.notice'
        end

        # リロードしたらフラッシュが消えること
        visit current_path
        expect(page).to have_no_selector 'div.flash'
      end
    end
  end

  feature 'ログアウト機能' do
    scenario 'ログアウトに成功し、フラッシュが表示されること' do
      sign_in user
      visit root_path

      within 'footer' do
        click_on 'ログアウト'
      end

      # ログアウトに成功すること
      expect(page).to have_current_path root_path, ignore_query: true
      within 'footer' do
        expect(page).to have_link 'ログイン', href: new_user_session_path
      end

      # フラッシュが表示されること
      within 'div.flash' do
        expect(page).to have_selector 'p.notice'
      end

      # リロードしたらフラッシュが消えること
      visit current_path
      expect(page).to have_no_selector 'div.flash'
    end
  end

  feature '自動ログイン機能', js: true do
    context 'ログイン状態を保持するにチェックせずにログインした場合' do
      scenario '自動ログインのCookieが生成されないこと' do
        visit new_user_session_path

        valid_fields = [{ locator: 'Eメール', value: user.email },
                        { locator: 'パスワード', value: user.password }]

        valid_fields.each do |valid_field|
          fill_in valid_field[:locator], with: valid_field[:value]
        end

        within 'div.main' do
          click_on 'ログイン'
        end

        # 自動ログインのCookieが生成されないこと
        cookies = page.driver.browser.manage.all_cookies.map { |c| c[:name] }
        expect(cookies).not_to include 'remember_user_token'
      end
    end

    context 'ログイン状態を保持するにチェックしてログインした場合' do
      scenario '自動ログインのCookieが生成されること' do
        visit new_user_session_path

        valid_fields = [{ locator: 'Eメール', value: user.email },
                        { locator: 'パスワード', value: user.password }]

        valid_fields.each do |valid_field|
          fill_in valid_field[:locator], with: valid_field[:value]
        end

        user_remember_me_label = find('label[for=user_remember_me]')
        user_remember_me_label.click

        within 'div.main' do
          click_on 'ログイン'
        end

        # 自動ログインのCookieが生成されること
        cookies = page.driver.browser.manage.all_cookies.map { |c| c[:name] }
        expect(cookies).to include 'remember_user_token'
      end
    end
  end

  feature 'フレンドリーフォワーディング' do
    context 'ログインが必要なページにアクセスした場合' do
      given!(:category) { create(:category) }

      scenario 'ログインしようとしたページにリダイレクトされること' do
        # ログインが必要なページにアクセスする
        visit edit_category_path(category)

        # ログインページにリダイレクトされること
        expect(page).to have_current_path new_user_session_path, ignore_query: true

        # フラッシュが表示されること
        within 'div.flash' do
          expect(page).to have_selector 'p.alert'
        end

        valid_fields = [{ locator: 'Eメール', value: user.email },
                        { locator: 'パスワード', value: user.password }]

        valid_fields.each do |valid_field|
          fill_in valid_field[:locator], with: valid_field[:value]
        end

        within 'div.main' do
          click_on 'ログイン'
        end

        # ログインしようとしたページにリダイレクトされること
        expect(page).to have_current_path edit_category_path(category), ignore_query: true

        # フラッシュが表示されること
        within 'div.flash' do
          expect(page).to have_selector 'p.notice'
        end

        # リロードしたらフラッシュが消えること
        visit current_path
        expect(page).to have_no_selector 'div.flash'
      end
    end
  end
end
