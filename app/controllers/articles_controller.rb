class ArticlesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :preview]
  authorize_resource only: [:create, :update, :destroy]
  before_action :set_category, except: [:preview]
  before_action :set_article, only: [:show, :edit, :update, :destroy]
  before_action :set_edit_menu, only: [:show, :edit]

  def show
    @category_tree = @category.category_tree
    @previous_article = @article.previous_article
    @next_article = @article.next_article

    # ログイン状態に基づきフィルタリングする
    unless user_signed_in?
      @previous_article = nil unless @previous_article&.published?
      @next_article = nil unless @next_article&.published?
    end
  end

  def new
    @article = @category.articles.build(
      article_order: @category.articles.count + 1
    )
  end

  def create
    @article = Article.new(article_params)
    @article.image.attach(params[:article][:image]) if params[:article][:image]
    if @article.save
      flash[:success] = "記事を投稿しました"
      redirect_to category_article_path(@article.category, @article)
    else
      render "new"
    end
  end

  def edit; end

  def update
    @article.assign_attributes(article_params)
    @article.image.attach(params[:article][:image]) if params[:article][:image]
    if @article.save
      flash[:success] = "記事を更新しました"
      @article.reload
      redirect_to category_article_path(@article.category, @article)
    else
      render "edit"
    end
  end

  def destroy
    @article.destroy
    flash[:success] = "記事を削除しました"
    redirect_to category_path(@category)
  end

  # マークダウンのプレビュー
  def preview
    @text = params[:text]
    render :preview, formats: :json
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

    if !user_signed_in? && !@article.published?
      message = "この記事は非公開になっています。"
      raise ApplicationError::NotPublishedError, message
    end
  end

  def set_edit_menu
    return unless user_signed_in?

    @edit_menu_list = [
      { text: "記事を編集する", path: edit_category_article_path(@category, @article), action: "edit" },
      { text: "記事を削除する", path: category_article_path(@category, @article), action: "destroy" }
    ]
  end
end
