class HabitInvitation < ApplicationRecord
  belongs_to :habit
  has_many :user_habit_invitations, dependent: :destroy

  def destroy_if_obselete!
    if self.user_habit_invitations.count == 0
      self.destroy!
    end
  end

end
