class Article < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy

  validates :title, :body, presence: true

  def editable_by?(user)
    return false if user.nil?

    user_id == user.id
  end
end
