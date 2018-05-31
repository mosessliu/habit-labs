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
    next_deadline = next_deadline() #next_deadline should not be nil because habit should have been sweeped already
    diff = next_deadline - curr

    if is_daily?
      return days_or_hours_left(diff)
    else
      weeks_left = diff / 1.weeks
      if weeks_left < 1
        return days_or_hours_left(diff)
      else
        return pluralize(weeks_left, "week")
      end
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

  def is_recurring?
    return duration > 0
  end

  def is_daily?
    return frequency == 0
  end

  def is_weekly?
    return frequency == 1
  end

  private 
  def days_or_hours_left(time)
    days_left = time / 1.days
    if days_left < 1 
      return pluralize((time / 1.hour).floor, "hour")
    end
    return pluralize(days_left.floor, "day")
  end

end
