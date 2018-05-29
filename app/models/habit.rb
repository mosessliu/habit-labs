class Habit < ApplicationRecord

  include ActionView::Helpers::TextHelper

  has_many :user_habits, dependent: :destroy
  has_many :users, through: :user_habits
  has_one :habit_invitation, dependent: :destroy

  validates :name, presence: true#, length: {minimum: 3}
  validates :description, presence: true#, length: {minimum: }
  validates :duration, presence: true
  validates :frequency, presence: true

  def get_time_left
    curr = DateTime.current
    next_deadline = next_deadline()

    #next_deadline should not be nil because habit should have been sweeped already

    diff = next_deadline - curr
    if self.frequency == 0
      days_left = diff / 1.days
      if days_left < 1 
        return pluralize((diff / 1.hours).floor, "hour")
      end
      return pluralize(days_left.floor, "day")
    else
      weeks_left = diff / 1.weeks
      if weeks_left < 1
        days_left = diff / 1.days
        if days_left < 1 
          return pluralize((diff / 1.hours).floor, "hour")
        end
        return pluralize(days_left.floor, "day")
      end
      return pluralize(weeks_left.floor, "week")
    end
  end 

  def next_deadline
    curr = DateTime.current
    for user_habit_deadline in self.user_habits.first.user_habit_deadlines.order("deadline ASC")
      deadline = user_habit_deadline.deadline
      if deadline > curr
        return deadline
      end
    end
    return nil
  end

  def is_complete_for_period?(user)
    next_deadline = next_deadline()
    user_habit = UserHabit.where(user: user, habit: self).first
    user_habit_deadline = UserHabitDeadline.where(user_habit: user_habit, deadline: next_deadline).first
    return user_habit_deadline.completed
  end

end
