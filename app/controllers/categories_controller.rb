class CategoriesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_category, only: [:show, :edit, :update, :destroy]

  def show
    @child_categories = @category.child_categories.sorted
    @category_tree = @category.category_tree
    @previous_category = @category.previous_category
    @next_category = @category.next_category
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
    if @category.save
      flash[:success] = 'カテゴリーを作成しました'
      redirect_to category_path(@category)
    else
      render 'new'
    end
  end

  def edit; end

  def update
    if @category.update(category_params)
      flash[:success] = 'カテゴリーを更新しました'
      @category.reload
      redirect_to category_path(@category)
    else
      render 'edit'
    end
  end

  def destroy
    parent_category = @category.parent_category
    @category.destroy
    flash[:success] = 'カテゴリーを削除しました'
    if parent_category
      redirect_to category_path(parent_category)
    else
      redirect_to root_path
    end
  end

  private

  def category_params
    params.require(:category).permit(:name, :title, :summary, :category_order,
                                     :parent_category_id)
  end

  def set_category
    @category = Category.friendly.find(params[:id])
  end
end
