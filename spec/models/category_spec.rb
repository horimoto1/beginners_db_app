# == Schema Information
#
# Table name: categories
#
#  id                 :bigint           not null, primary key
#  category_order     :integer          not null
#  name               :string           not null
#  slug               :string           default(""), not null
#  summary            :text
#  title              :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  parent_category_id :integer
#
# Indexes
#
#  index_categories_on_name   (name) UNIQUE
#  index_categories_on_slug   (slug) UNIQUE
#  index_categories_on_title  (title) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (parent_category_id => categories.id)
#
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
      context "空の場合" do
        it "バリデーションが通らないこと" do
          category.name = ""
          expect(category).not_to be_valid
        end
      end

      context "重複する場合" do
        it "バリデーションが通らないこと" do
          category.save
          duplicate_category = build(:category, name: category.name)
          expect(duplicate_category).not_to be_valid
        end
      end
    end

    context "titleが不正の場合" do
      context "空の場合" do
        it "バリデーションが通らないこと" do
          category.title = ""
          expect(category).not_to be_valid
        end
      end

      context "重複する場合" do
        it "バリデーションが通らないこと" do
          category.save
          duplicate_category = build(:category, title: category.title)
          expect(duplicate_category).not_to be_valid
        end
      end
    end

    context "category_orderが不正の場合" do
      context "空の場合" do
        it "バリデーションが通らないこと" do
          category.category_order = nil
          expect(category).not_to be_valid
        end
      end
    end

    context "parent_category_idが不正の場合" do
      context "参照先が存在しない場合" do
        it "バリデーションが通らないこと" do
          category.parent_category_id = -1
          expect(category).not_to be_valid
        end
      end
    end
  end

  describe "スコープ" do
    describe "#sorted" do
      # 最小のcategory_orderを持つCategoryを複数作成する
      let!(:categories_order_1) { create_list(:category, 3, category_order: 1) }

      before do
        create(:category, category_order: 3)
        create(:category, category_order: 2)
      end

      it "category_orderとidが最小のCategoryが先頭に来ること" do
        expect(Category.sorted.first).to eq categories_order_1.min_by(&:id)
      end
    end

    describe "#root_categories" do
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

    describe "子カテゴリーが存在する場合" do
      before do
        create(:category, parent_category_id: category.id)
      end

      it "削除できないこと" do
        expect { category.destroy }.not_to change { Category.count }
      end
    end

    describe "記事が存在する場合" do
      before do
        create(:article, category_id: category.id)
      end

      it "削除できないこと" do
        expect { category.destroy }.not_to change { Category.count }
      end
    end
  end

  describe "#should_generate_new_friendly_id?" do
    let!(:category) { create(:category) }

    it "nameが更新されるとslugも自動で更新されること" do
      new_category_name = "sample"
      category.update(name: new_category_name)
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
        before do
          create(:category, category_order: 3,
                            parent_category_id: root_categories.first.id)
        end

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
        before do
          create(:category, category_order: 1,
                            parent_category_id: root_categories.first.id)
        end

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

    it "呼び出し元と祖先Categoryを全て取得できること" do
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
