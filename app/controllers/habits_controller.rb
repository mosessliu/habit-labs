class HabitsController < ApplicationController

  FREQUENCY = {0 => "Daily", 1 => "Weekly"}


  def new
    session[:new_habit_participants] = [current_user.to_json, User.first.to_json]
  end

  def create
    habit = create_habit
    habit.save
  end

  def add_participant
    added_participant= User.find(params[:added_participant])

    session[:new_habit_participants].push(added_participant.to_json)
    flash.now[:success] = "You have added #{added_participant.full_name} as a participant!"

    respond_to do |format|
       format.js {render partial: "shared/response_to_adding_participant.js"}
    end
  end

  def build_habit
    puts "hello?"
    render 'habits/build_habit.html'
  end

  def show

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