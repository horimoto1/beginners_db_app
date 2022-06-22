Category.all.each do |category|
  create_list(:article, 5, category_id: category.id)

  create_list(:article, 5, category_id: category.id, published: true)
end
