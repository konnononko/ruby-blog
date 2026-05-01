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
end
