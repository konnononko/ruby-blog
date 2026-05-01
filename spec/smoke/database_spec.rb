require "rails_helper"

RSpec.describe "Database smoke test" do
  it "connects to the database" do
    expect(ActiveRecord::Base.connection).to be_active
  end

  it "can run a simple query" do
    value = ActiveRecord::Base.connection.select_value("SELECT 1")
    expect(value.to_i).to eq(1)
  end
end

