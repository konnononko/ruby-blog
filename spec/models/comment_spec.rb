require "rails_helper"

RSpec.describe Comment, type: :model do
  let(:author) do
    User.create!(
      email: "comment-author-#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  let(:commenter) do
    User.create!(
      email: "comment-commenter-#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  let(:stranger) do
    User.create!(
      email: "comment-stranger-#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  let(:article) { author.articles.create!(title: "Title", body: "Body text") }

  it "is invalid without a body" do
    comment = described_class.new(user: commenter, article: article)

    expect(comment).not_to be_valid
    expect(comment.errors[:body]).to be_present
  end

  describe "#deletable_by?" do
    let(:comment) { described_class.create!(article: article, user: commenter, body: "Hi") }

    it "returns false for nil" do
      expect(comment.deletable_by?(nil)).to be false
    end

    it "returns true for the commenter" do
      expect(comment.deletable_by?(commenter)).to be true
    end

    it "returns true for the article author" do
      expect(comment.deletable_by?(author)).to be true
    end

    it "returns false for an unrelated user" do
      expect(comment.deletable_by?(stranger)).to be false
    end
  end
end
