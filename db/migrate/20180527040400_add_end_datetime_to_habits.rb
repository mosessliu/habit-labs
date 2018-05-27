class AddEndDatetimeToHabits < ActiveRecord::Migration[5.2]
  def change
    add_column :habits, :end_datetime, :datetime
  end
end
