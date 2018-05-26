class UserHabit < ApplicationRecord
  belongs_to :user
  belongs_to :habit

  has_many :user_habit_deadlines
end