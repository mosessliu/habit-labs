class UserHabitDeadline < ApplicationRecord
  belongs_to :user_habit


  def self.get_next_user_habit_deadline(user_habit)
    user_habit_deadlines = user_habit.user_habit_deadlines.order('deadline ASC')
    current_date_time = DateTime.current
  
    for user_habit_deadline in user_habit_deadlines
      deadline = user_habit_deadline.deadline
      if deadline >= current_date_time
        return user_habit_deadline
      end
    end
    return nil
  end

end