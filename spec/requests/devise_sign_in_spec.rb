require "rails_helper"

RSpec.describe "Devise sign in", type: :request do
  it "renders the sign in page" do
    get new_user_session_path

    expect(response).to have_http_status(:ok)
  end
end
