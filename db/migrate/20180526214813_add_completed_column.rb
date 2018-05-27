class AddCompletedColumn < ActiveRecord::Migration[5.2]
  def change
    add_column :user_habit_deadlines, :completed, :boolean, default: false
  end
end
