module ApplicationHelper
  # 型に応じたパスを返す
  def object_path(object)
    case object
    when Category
      category_path(object)
    when Article
      category_article_path(object.category, object)
    end
  end

  # ページごとの完全なタイトルを返す
  def full_title(page_title = "")
    base_title = "BeginnersDB"
    page_title.empty? ? base_title : page_title + " | " + base_title
  end
end
