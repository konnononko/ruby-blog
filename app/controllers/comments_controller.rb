class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_article

  def create
    @comment = @article.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to @article, notice: "Comment was successfully added."
    else
      redirect_to @article, alert: @comment.errors.full_messages.to_sentence
    end
  end

  def destroy
    @comment = @article.comments.find(params[:id])

    unless @comment.deletable_by?(current_user)
      redirect_to @article, alert: "You are not allowed to delete this comment."
      return
    end

    @comment.destroy
    redirect_to @article, notice: "Comment was successfully deleted."
  end

  private

  def set_article
    @article = Article.find(params[:article_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
