class Board < ApplicationRecord
    has_many :lists, -> { order(position: :asc) }, dependent: :destroy
end
