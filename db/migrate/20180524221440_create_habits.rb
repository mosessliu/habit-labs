class CreateHabits < ActiveRecord::Migration[5.2]
  def change
    create_table :habits do |t|
      t.string :name
      t.text :description
      t.integer :duration
      t.integer :frequency

      t.timestamps
    end
  end
end
