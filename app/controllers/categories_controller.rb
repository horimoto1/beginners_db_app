class CategoriesController < ApplicationController
  before_action :set_category, only: [:show, :edit, :update, :destroy]

  def show
    @categories = [@category] + @category.child_categories
    @breadcrumb_list = @category.breadcrumb_list
    @previous_category = @category.previous_category
    @next_category = @category.next_category
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to edit_category_path(@category)
    else
      render "new"
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      redirect_to edit_category_path(@category)
    else
      render "edit"
    end
  end

  def destroy
    @category.destroy
    redirect_to new_category_path
  end

  private

  def category_params
    params.require(:category).permit(:name, :title, :summary,
                                     :category_order, :parent_category_id)
  end

  def set_category
    @category = Category.friendly.find(params[:id])
  end
end
