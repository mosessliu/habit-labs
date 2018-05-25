class HabitsController < ApplicationController

  FREQUENCY = {0 => "Daily", 1 => "Weekly"}

  def new
  end

  def create
    habit = create_habit
    habit.save
  end

  private
  def create_habit
    habit_params = params[:habit]

    name = habit_params[:name]
    description = habit_params[:description]
    frequency = habit_params[:frequency]
    duration = habit_params[:duration]

    return Habit.new(name: name, description: description, frequency: frequency, duration: duration)
  end

end