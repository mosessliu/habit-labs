class HabitInvitation < ApplicationRecord
  belongs_to :habit
  has_many :user_habit_invitations
end
