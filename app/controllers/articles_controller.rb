class ArticlesController < ApplicationController
  before_action :set_category
  before_action :set_article, only: [:show, :edit, :update, :destroy]

  def show
    @breadcrumb_list = @category.breadcrumb_list
    @previous_article = @article.previous_article
    @next_article = @article.next_article
  end

  def new
    @article = Article.new
    @article.category_id = @category.id
    @article.article_order = @category.articles.count + 1
  end

  def create
    @article = Article.new(article_params)
    if @article.save
      redirect_to category_article_path(@category, @article)
    else
      render "new"
    end
  end

  def edit
  end

  def update
    if @article.update(article_params)
      redirect_to category_article_path(@category, @article)
    else
      render "edit"
    end
  end

  def destroy
    @article.destroy
    redirect_to category_path(@category)
  end

  private

  def article_params
    params.require(:article).permit(:name, :title, :summary, :content,
                                    :article_order, :status, :category_id)
  end

  def set_category
    @category = Category.friendly.find(params[:category_id])
  end

  def set_article
    @article = @category.articles.friendly.find(params[:id])
  end
end
