FactoryBot.create_list(:category, 3)

Category.all.each do |root_category|
  FactoryBot.create_list(:category, 3, parent_category_id: root_category.id)
end
