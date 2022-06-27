class ArticlesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_category
  before_action :set_article, only: [:show, :edit, :update, :destroy]

  def show
    @category_tree = @category.category_tree
    @previous_article = login_filter(@article.previous_article)
    @next_article = login_filter(@article.next_article)
  end

  def new
    @article = @category.articles.build(
      article_order: @category.articles.count + 1
    )
  end

  def create
    @article = Article.new(article_params)
    if @article.save
      flash[:success] = '記事を投稿しました'
      redirect_to category_article_path(@article.category, @article)
    else
      render 'new'
    end
  end

  def edit; end

  def update
    if @article.update(article_params)
      flash[:success] = '記事を更新しました'
      @article.reload
      redirect_to category_article_path(@article.category, @article)
    else
      render 'edit'
    end
  end

  def destroy
    @article.destroy
    flash[:success] = '記事を削除しました'
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

    unless login_filter(@article)
      message = 'この記事は非公開になっています。'
      raise ApplicationError::NotPublishedError, message
    end
  end
end
