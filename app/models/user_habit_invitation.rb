class UserHabitInvitation < ApplicationRecord
  belongs_to :user
  belongs_to :habit_invitation
end
