class ArticlesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  def index
    @articles = params[:author].present? ? Article.authored_by(params[:author]) : Article.all.includes(:user)
    @articles = @articles.tagged_with(params[:tag]) if params[:tag].present?
    @articles = @articles.favorited_by(params[:favorited]) if params[:favorited].present?
    @articles_count = @articles.count
    @articles = @articles.order(created_at: :desc).offset(params[:offset] || 0).limit(params[:limit] || 20)
  end

  def feed
    @articles = Article.includes(:user).where(user: current_user.following_users)
    @articles_count = @articles.count
    @articles = @articles.order(created_at: :desc).offset(params[:offset] || 0).limit(params[:limit] || 20)
    render :index
  end

  def create
    @article = current_user.articles.new(article_params)

    if @article.save!
      render :show
    else
      render json: { errors: @article.errors }, statue: :unprocessable_entity
    end
  end

  def show
    @article = Article.find_by_slug!(params[:slug])
  end

  def update
    @article = Article.find_by_slug!(params[:slug])

    if @article.user_id == @current_user_id
      @article.update_attributes(article_params)
      render :show
    else
      render json: { errors: { article: ['not owned by user'] } }, status: :forbidden
    end
  end

  def destroy
    @article = Article.find_by_slug!(params[:slug])

    if @article.user_id == @current_user_id
      @article.destroy
      render json: {}
    else
      render json: { errors: { article: ['not owned by user'] } }, status: :forbidden
    end
  end

  private

  def article_params
    params.require(:article).permit(:title, :body, :description, tag_list: [])
  end
end