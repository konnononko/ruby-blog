class Comment < ApplicationRecord
  belongs_to :article
  belongs_to :user

  validates :body, presence: true

  def deletable_by?(user)
    return false if user.nil?

    user_id == user.id || article.user_id == user.id
  end
end
