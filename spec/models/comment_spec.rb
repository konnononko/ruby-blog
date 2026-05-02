require "rails_helper"

RSpec.describe Comment, type: :model do
  let(:user) do
    User.create!(
      email: "comment-model-#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  let(:article) { user.articles.create!(title: "Title", body: "Body text") }

  it "is invalid without a body" do
    comment = described_class.new(user: user, article: article)

    expect(comment).not_to be_valid
    expect(comment.errors[:body]).to be_present
  end
end
