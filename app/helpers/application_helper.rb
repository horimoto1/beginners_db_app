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
end
