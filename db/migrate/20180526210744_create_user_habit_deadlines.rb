class CreateUserHabitDeadlines < ActiveRecord::Migration[5.2]
  def change
    create_table :user_habit_deadlines do |t|
      t.references :user_habit
      t.datetime :deadline
    end
  end
end
