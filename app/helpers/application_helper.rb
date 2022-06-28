module ApplicationHelper
  # ページごとの完全なタイトルを返す
  def full_title(page_title = "")
    base_title = "BeginnersDB"
    page_title.empty? ? base_title : "#{page_title} | #{base_title}"
  end

  # 型に応じたパスを返す
  def object_path(object)
    case object
    when Category
      category_path(object)
    when Article
      category_article_path(object.category, object)
    end
  end

  # ログイン状態に基づきフィルタリングする
  def login_filter(object)
    return nil unless object

    return object if user_signed_in?

    case object
    when ActiveRecord::Relation
      object.model == Article ? object.published : object
    when Article
      object.published? ? object : nil
    else
      object
    end
  end
end
