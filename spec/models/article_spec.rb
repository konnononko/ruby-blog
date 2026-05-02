require "rails_helper"

RSpec.describe Article, type: :model do
  let(:user) do
    User.create!(
      email: "writer@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  it "is invalid without a title" do
    article = described_class.new(body: "Body text", user: user)

    expect(article).not_to be_valid
    expect(article.errors[:title]).to be_present
  end

  describe "#editable_by?" do
    let(:other) do
      User.create!(
        email: "other-article-#{SecureRandom.hex(4)}@example.com",
        password: "password123",
        password_confirmation: "password123"
      )
    end

    let(:article) { user.articles.create!(title: "T", body: "B") }

    it "returns false for nil" do
      expect(article.editable_by?(nil)).to be false
    end

    it "returns true for the owner" do
      expect(article.editable_by?(user)).to be true
    end

    it "returns false for another user" do
      expect(article.editable_by?(other)).to be false
    end
  end
end
