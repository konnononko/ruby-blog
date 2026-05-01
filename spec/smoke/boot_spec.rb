require "rails_helper"

RSpec.describe "Boot smoke test" do
  it "boots the Rails application" do
    expect(Rails.application).to be_a(Rails::Application)
  end
end

