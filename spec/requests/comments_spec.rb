require "rails_helper"

RSpec.describe "Comments", type: :request do
  let(:author) do
    User.create!(
      email: "author-#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  let(:commenter) do
    User.create!(
      email: "commenter-#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  let(:article) { author.articles.create!(title: "Post", body: "Body text") }

  describe "POST /articles/:article_id/comments" do
    it "redirects guests to sign in" do
      post article_comments_path(article), params: { comment: { body: "Nice" } }

      expect(response).to redirect_to(new_user_session_path)
    end

    it "creates a comment when signed in" do
      sign_in commenter

      expect do
        post article_comments_path(article), params: { comment: { body: "Nice post" } }
      end.to change(Comment, :count).by(1)

      expect(response).to redirect_to(article_path(article))
      comment = Comment.last
      expect(comment.user_id).to eq(commenter.id)
      expect(comment.article_id).to eq(article.id)
      expect(comment.body).to eq("Nice post")
    end
  end

  describe "DELETE /articles/:article_id/comments/:id" do
    let!(:comment) do
      Comment.create!(article: article, user: commenter, body: "Hello")
    end

    it "does not allow a stranger to delete" do
      stranger = User.create!(
        email: "stranger-#{SecureRandom.hex(4)}@example.com",
        password: "password123",
        password_confirmation: "password123"
      )
      sign_in stranger

      expect do
        delete article_comment_path(article, comment)
      end.not_to change(Comment, :count)

      expect(response).to redirect_to(article_path(article))
    end

    it "allows the commenter to delete" do
      sign_in commenter

      expect do
        delete article_comment_path(article, comment)
      end.to change(Comment, :count).by(-1)

      expect(response).to redirect_to(article_path(article))
    end

    it "allows the article author to delete" do
      sign_in author

      expect do
        delete article_comment_path(article, comment)
      end.to change(Comment, :count).by(-1)
    end
  end
end
