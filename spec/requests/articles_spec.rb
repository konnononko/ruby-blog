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
  end
end
