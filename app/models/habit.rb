class Habit < ApplicationRecord
  has_many :user_habits
  has_many :users, through: :user_habits

  validates :name, presence: true#, length: {minimum: 3}
  validates :description, presence: true#, length: {minimum: }
  validates :duration, presence: true
  validates :frequency, presence: true

end
