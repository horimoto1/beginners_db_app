require "rails_helper"

RSpec.describe Category, type: :model do
  describe "バリデーション" do
    let!(:category) { build(:category) }

    context "全ての属性が正しい場合" do
      it "バリデーションが通ること" do
        expect(category).to be_valid
      end
    end

    context "nameが不正の場合" do
      it "空ならばバリデーションが通らないこと" do
        category.name = ""
        expect(category).not_to be_valid
      end

      it "重複するならばバリデーションが通らないこと" do
        category.save
        duplicate_category = build(:category, name: category.name)
        expect(duplicate_category).not_to be_valid
      end
    end

    context "titleが不正の場合" do
      it "空ならばバリデーションが通らないこと" do
        category.title = ""
        expect(category).not_to be_valid
      end

      it "重複するならばバリデーションが通らないこと" do
        category.save
        duplicate_category = build(:category, title: category.title)
        expect(duplicate_category).not_to be_valid
      end
    end

    context "category_orderが不正の場合" do
      it "空ならばバリデーションが通らないこと" do
        category.category_order = nil
        expect(category).not_to be_valid
      end
    end

    context "parent_category_idが不正の場合" do
      it "参照先が存在しなければバリデーションが通らないこと" do
        category.parent_category_id = -1
        expect(category).not_to be_valid
      end
    end
  end

  describe "スコープ" do
    context "category_orderの昇順でソートされ、タイはidの昇順でソートされること" do
      # 最小のcategory_orderを持つCategoryを複数作成する
      let!(:category_3) { create(:category, category_order: 3) }
      let!(:category_2) { create(:category, category_order: 2) }
      let!(:categories_1) { create_list(:category, 3, category_order: 1) }

      it "category_orderとidが最小のCategoryが先頭に来ること" do
        expect(Category.sorted.first).to eq categories_1.min_by { |category| category.id }
      end
    end

    context "ルートCategory一覧を取得すること" do
      let!(:root_categories) { create_list(:category, 3) }
      let!(:child_categories) {
        create_list(:category, 3,
                    parent_category_id: root_categories.first.id)
      }

      it "ルートCategoryが全て含まれること" do
        root_categories.each do |root_category|
          expect(Category.root_categories).to include root_category
        end
      end

      it "非ルートCategoryが全て含まれないこと" do
        child_categories.each do |child_category|
          expect(Category.root_categories).not_to include child_category
        end
      end
    end
  end

  describe "アソシエーション" do
    let!(:category) { create(:category) }
    let!(:child_category) { create(:category, parent_category_id: category.id) }
    let!(:article) { create(:article, category_id: category.id) }

    it "削除時に子Categoryも削除されること" do
      expect { category.destroy }.to change { Category.count }.by(-2)
    end

    it "削除時に関連するArticleも削除されること" do
      expect { category.destroy }.to change { Article.count }.by(-1)
    end
  end

  describe "#should_generate_new_friendly_id?" do
    let!(:category) { create(:category) }

    it "nameが更新されるとslugも自動で更新されること" do
      new_category_name = "sample"
      category.update_attributes(name: new_category_name)
      expect(category.slug).to eq new_category_name.parameterize
    end
  end

  describe "#previous_category" do
    let!(:root_categories) { create_list(:category, 3) }
    let!(:category) {
      create(:category, category_order: 2,
                        parent_category_id: root_categories.first.id)
    }

    context "同一の親Categoryに属すCategoryが存在しない" do
      it "nilが返されること" do
        expect(category.previous_category).to be_nil
      end
    end

    context "同一の親Categoryに属すCategoryが存在する" do
      context "category_orderが小さいCategoryが存在する" do
        let!(:category_lt) {
          create(:category, category_order: 1,
                            parent_category_id: root_categories.first.id)
        }

        it "前のCategoryを取得できること" do
          expect(category.previous_category).to eq category_lt
        end
      end

      context "category_orderが小さいCategoryが存在しない" do
        let!(:category_gt) {
          create(:category, category_order: 3,
                            parent_category_id: root_categories.first.id)
        }

        it "nilが返されること" do
          expect(category.previous_category).to be_nil
        end
      end

      context "category_orderがタイのCategoryが存在する" do
        let!(:category_eq) {
          create(:category, category_order: 2,
                            parent_category_id: root_categories.first.id)
        }

        context "idが小さいCategoryが存在する" do
          it "前のCategoryを取得できること" do
            expect(category_eq.previous_category).to eq category
          end
        end

        context "idが小さいCategoryが存在しない" do
          it "nilが返されること" do
            expect(category.previous_category).to be_nil
          end
        end
      end
    end
  end

  describe "#next_category" do
    let!(:root_categories) { create_list(:category, 3) }
    let!(:category) {
      create(:category, category_order: 2,
                        parent_category_id: root_categories.first.id)
    }

    context "同一の親Categoryに属すCategoryが存在しない" do
      it "nilが返されること" do
        expect(category.next_category).to be_nil
      end
    end

    context "同一の親Categoryに属すCategoryが存在する" do
      context "category_orderが大きいCategoryが存在する" do
        let!(:category_gt) {
          create(:category, category_order: 3,
                            parent_category_id: root_categories.first.id)
        }

        it "次のCategoryを取得できること" do
          expect(category.next_category).to eq category_gt
        end
      end

      context "category_orderが大きいCategoryが存在しない" do
        let!(:category_lt) {
          create(:category, category_order: 1,
                            parent_category_id: root_categories.first.id)
        }

        it "nilが返されること" do
          expect(category.next_category).to be_nil
        end
      end

      context "category_orderがタイのCategoryが存在する" do
        let!(:category_eq) {
          create(:category, category_order: 2,
                            parent_category_id: root_categories.first.id)
        }

        context "idが大きいCategoryが存在する" do
          it "次のCategoryを取得できること" do
            expect(category.next_category).to eq category_eq
          end
        end

        context "idが大きいCategoryが存在しない" do
          it "nilが返されること" do
            expect(category_eq.next_category).to be_nil
          end
        end
      end
    end
  end

  describe "#category_tree" do
    let!(:root_category) { create(:category) }
    let!(:child_category) { create(:category, parent_category_id: root_category.id) }
    let!(:grandchild_category) { create(:category, parent_category_id: child_category.id) }
    let!(:category_list) { [root_category, child_category, grandchild_category] }

    it "祖先Categoryを全て含むツリーを取得できること" do
      category_list.each do |category|
        expect(grandchild_category.category_tree).to include category
      end
    end

    it "ルートCategoryは先頭であること" do
      expect(grandchild_category.category_tree.first).to eq root_category
    end

    it "呼び出し元は末尾であること" do
      expect(grandchild_category.category_tree.last).to eq grandchild_category
    end
  end
end
