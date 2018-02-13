class Notebook < ApplicationRecord
  belongs_to :user
  has_many :chunks, dependent: :destroy
end
