class Habit < ApplicationRecord
  has_many :user_habits, dependent: :destroy
  has_many :users, through: :user_habits
  has_one :habit_invitation, dependent: :destroy


  validates :name, presence: true#, length: {minimum: 3}
  validates :description, presence: true#, length: {minimum: }
  validates :duration, presence: true
  validates :frequency, presence: true

end
