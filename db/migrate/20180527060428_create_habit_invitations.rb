class CreateHabitInvitations < ActiveRecord::Migration[5.2]
  def change
    create_table :habit_invitations do |t|
      t.references :habit, foreign_key: true

      t.timestamps
    end
  end
end
