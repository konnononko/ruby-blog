require "rails_helper"

RSpec.describe "Articles", type: :request do
  let(:user) do
    User.create!(
      email: "writer@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

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
end
