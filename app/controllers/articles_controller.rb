class ArticlesController < ApplicationController
  before_action :set_category
  before_action :set_article, only: [:show, :edit, :update, :destroy]

  def show
  end

  def new
    @article = Article.new
    @article.category_id = @category.id
  end

  def create
    @article = Article.new(article_params)
    if @article.save
      redirect_to edit_category_article_path(@category, @article)
    else
      render "new"
    end
  end

  def edit
  end

  def update
    if @article.update(article_params)
      redirect_to edit_category_article_path(@category, @article)
    else
      render "edit"
    end
  end

  def destroy
    @article.destroy
    redirect_to new_category_article_path(@category)
  end

  private

  def article_params
    params.require(:article).permit(:name, :title, :content, :article_order,
                                    :status, :category_id)
  end

  def set_category
    @category = Category.find(params[:category_id])
  end

  def set_article
    @article = Article.find(params[:id])
  end
end
