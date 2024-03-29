class CategoriesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  authorize_resource only: [:create, :update, :destroy]
  before_action :set_category, only: [:show, :edit, :update, :destroy]
  before_action :set_edit_menu, only: [:show, :edit]

  def show
    @child_categories = @category.child_categories.sorted
    @category_tree = @category.category_tree
    @previous_category = @category.previous_category
    @next_category = @category.next_category

    # 必要なレコードを先読みする
    @child_categories = @child_categories.with_articles.merge(Article.with_attached_image).merge(Article.sorted)

    # ログイン状態に基づきフィルタリングする
    unless user_signed_in?
      @child_categories = @child_categories.merge(Article.published)
      @previous_category = nil if @previous_category && @previous_category.articles.published.count.zero?
      @next_category = nil if @next_category && @next_category.articles.published.count.zero?
    end
  end

  def new
    if params[:parent_category_id]
      parent_category = Category.friendly.find(params[:parent_category_id])
      @category = parent_category.child_categories.build(
        category_order: parent_category.child_categories.count + 1
      )
    else
      @category = Category.new
      @category.category_order = @root_categories.count + 1
    end
  end

  def create
    @category = Category.new(category_params)
    @category.image.attach(params[:category][:image]) if params[:category][:image]
    if @category.save
      flash[:success] = "カテゴリーを作成しました"
      redirect_to category_path(@category)
    else
      render "new"
    end
  end

  def edit; end

  def update
    @category.assign_attributes(category_params)
    @category.image.attach(params[:category][:image]) if params[:category][:image]
    if @category.save
      flash[:success] = "カテゴリーを更新しました"
      @category.reload
      redirect_to category_path(@category)
    else
      render "edit"
    end
  end

  def destroy
    if @category.destroy
      flash[:success] = "カテゴリーを削除しました"

      if @category.parent_category
        redirect_to category_path(@category.parent_category)
      else
        redirect_to root_path
      end
    else
      flash[:alert] = "記事または子カテゴリーが存在するため削除できません"

      redirect_to request.referer || root_path
    end
  end

  private

  def category_params
    params.require(:category).permit(:name, :title, :summary, :category_order,
                                     :parent_category_id)
  end

  def set_category
    @category = Category.where(slug: params[:id]).or(Category.where(id: params[:id]))

    # 必要なレコードを先読みする
    @category = @category.with_articles.merge(Article.with_attached_image).merge(Article.sorted)

    # ログイン状態に基づきフィルタリングする
    unless user_signed_in?
      @category = @category.merge(Article.published)
    end

    @category = @category.to_a.first

    raise ActiveRecord::RecordNotFound unless @category
  end

  def set_edit_menu
    return unless user_signed_in?

    @edit_menu_list = [
      { text: "カテゴリーを作成する", path: new_category_path(parent_category_id: @category.id), action: "new" },
      { text: "カテゴリーを編集する", path: edit_category_path(@category), action: "edit" },
      { text: "記事を投稿する", path: new_category_article_path(@category), action: "new" },
      { text: "カテゴリーを削除する", path: category_path(@category), action: "destroy" }
    ]
  end
end
