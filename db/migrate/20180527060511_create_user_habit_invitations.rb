class CreateUserHabitInvitations < ActiveRecord::Migration[5.2]
  def change
    create_table :user_habit_invitations do |t|
      t.references :user, foreign_key: true
      t.references :habit_invitation, foreign_key: true

      t.timestamps
    end
  end
end
