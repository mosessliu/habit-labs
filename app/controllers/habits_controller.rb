class HabitsController < ApplicationController

  FREQUENCY = {0 => "Daily", 1 => "Weekly"}


  def new
    set_default_participants
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
    @habit = Habit.new
    render 'habits/build_habit.html'
  end

  def create
    @habit = create_habit
    if @habit.save
      assign_habit_to_participants
      redirect_to root_path
    else
      render 'habits/build_habit.html'
    end
  end

  def show

  end



  private
  def set_default_participants
    session[:new_habit_participants] = [current_user.to_json, User.first.to_json]
  end
  def create_habit
    habit_params = params[:habit]

    name = habit_params[:name]
    description = habit_params[:description]
    frequency = habit_params[:frequency]
    duration = habit_params[:duration]

    return Habit.new(name: name, description: description, frequency: frequency, duration: duration)
  end

  def assign_habit_to_participants
    for json in session[:new_habit_participants]
      user = User.get_object(json)
      UserHabit.create(user: user, habit: @habit)
    end
  end

end