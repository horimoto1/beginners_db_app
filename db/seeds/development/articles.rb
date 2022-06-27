Category.all.each do |category|
  FactoryBot.create_list(:article, 5, category_id: category.id)

  FactoryBot.create_list(:article, 5, category_id: category.id, published: true)
end
