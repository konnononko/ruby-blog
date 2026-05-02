require "rails_helper"

RSpec.describe "Articles", type: :request do
  let(:user) do
    User.create!(
      email: "writer@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  let(:other_user) do
    User.create!(
      email: "other-writer-#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  let(:owned_article) { user.articles.create!(title: "Owned", body: "Body") }

  describe "GET /articles" do
    it "returns success for guests" do
      get articles_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /articles/new" do
    it "redirects guests to sign in" do
      get new_article_path

      expect(response).to redirect_to(new_user_session_path)
    end

    it "returns success when signed in" do
      sign_in user

      get new_article_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /articles" do
    it "redirects guests to sign in" do
      post articles_path, params: { article: { title: "Hello", body: "World" } }

      expect(response).to redirect_to(new_user_session_path)
    end

    it "creates an article when signed in" do
      sign_in user

      expect do
        post articles_path, params: {
          article: { title: "My title", body: "My body text" }
        }
      end.to change(Article, :count).by(1)

      article = Article.last
      expect(response).to redirect_to(article_path(article))
      expect(article.user_id).to eq(user.id)
      expect(article.title).to eq("My title")
      expect(article.body).to eq("My body text")
    end
  end

  describe "GET /articles/:id/edit" do
    it "redirects when signed in as non-owner" do
      sign_in other_user

      get edit_article_path(owned_article)

      expect(response).to redirect_to(articles_path)
    end
  end

  describe "PATCH /articles/:id" do
    it "redirects without updating when signed in as non-owner" do
      sign_in other_user

      patch article_path(owned_article), params: {
        article: { title: "Hacked title", body: "Hacked body" }
      }

      expect(response).to redirect_to(articles_path)
      owned_article.reload
      expect(owned_article.title).to eq("Owned")
      expect(owned_article.body).to eq("Body")
    end
  end

  describe "DELETE /articles/:id" do
    it "redirects without destroying when signed in as non-owner" do
      owned_article
      sign_in other_user

      expect do
        delete article_path(owned_article)
      end.not_to change(Article, :count)

      expect(response).to redirect_to(articles_path)
      expect(Article.exists?(owned_article.id)).to be true
    end
  end
end
