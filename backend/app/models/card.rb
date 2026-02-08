class Card < ApplicationRecord
  belongs_to :list

  scope :for_user, ->(user) { joins(list: :board).where(boards: { user_id: user.id }) }
end
