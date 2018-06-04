class HabitsController < ApplicationController

  def new
    set_default_participant
    render 'habits/set_participants_new'
  end

  def add_participant
    if session[:new_habit_participants].count >= 5
      flash.now[:danger] = "You cannot invite anymore participants to this habit!"
    else
      id = params[:added_participant]
      session[:new_habit_participants].push(id)
      added_participant = User.find(id)
      flash.now[:success] = "You have added #{added_participant.full_name} as a participant!"
    end

    respond_to do |format|
      format.js {render partial: "shared/response_to_change_in_participants.js"}
    end

  end

  def remove_participant
    to_be_removed = params[:participant_id]


    if to_be_removed.to_s == current_user.id.to_s
      flash.now[:danger] = "You must be a part of habits you create."
    else
      flash.now[:success] = "You have removed #{User.find(to_be_removed).full_name} from this habit"
      session[:new_habit_participants].delete_if { |user_id| user_id.to_s == to_be_removed.to_s} 
    end
    respond_to do |format|
      format.js {render partial: "shared/response_to_change_in_participants.js"}
    end
  end

  def back_to_edit_participants
    if is_habit_refresh?
      @habit = Habit.find(params[:habit_id])
      render 'habits/set_participants_refresh'
    else
      render 'habits/set_participants_new'
    end
  end

  def build_habit_new
    @habit = Habit.new
    render 'habits/build_habit_new.html'
  end

  def create
    @habit = create_habit
    if @habit.save
      @current_date_time = DateTime.current
      assign_habit_to_participants
      send_invitation_to_participants
      set_habit_end_datetime
      redirect_to root_path
    else
      render 'habits/build_habit_new.html'
    end
  end

  def show
    @habit= Habit.find(params[:id])
    @user_habit = UserHabit.where(user: current_user, habit: @habit).first
    if @user_habit.blank?
      #habit does not exist for this user
      redirect_to root_path
    end
  end

  def accept_habit_invitation
    #accept habit by deleting the user's user_habit_invitation
    habit = Habit.find(params[:habit_id])
    habit_invitation = habit.habit_invitation
    user_habit_invitation = UserHabitInvitation.where(user: current_user, habit_invitation: habit_invitation).first
    if user_habit_invitation.destroy!
      flash[:success] = "You have accepted your invitation to '#{habit.name}'"
    else
      flash[:danger] = "Unable to accept invitation to '#{habit.name}'. Try again later."
    end
    redirect_to root_path
  end

  def refresh_habit
    @habit = Habit.find(params[:habit_id])
    set_default_participants(@habit.users)
    render 'habits/set_participants_refresh'
  end

  def build_habit_refresh
    @habit = Habit.find(params[:habit_id])
    render 'habits/build_habit_refresh'
  end

  def create_refreshed_habit
    create_habit
    @habit = create_habit
    if @habit.save
      @current_date_time = DateTime.current
      assign_habit_to_participants
      send_invitation_to_participants
      set_habit_end_datetime

      # old_habit = Habit.find(params[:old_id])
      # old_habit.destroy!
      redirect_to root_path
    else
      render 'habits/build_habit_refresh.html'
    end
  end

  private
  def set_default_participant
    session[:new_habit_participants] = [current_user.id]
  end

  def set_default_participants(users)
    session[:new_habit_participants] = []
    for user in users
      if user.id.to_s == current_user.id.to_s
        session[:new_habit_participants].insert(0, user.id)
      else
        session[:new_habit_participants] << user.id
      end
    end
  end

  def create_habit
    habit_params = params.require(:habit).permit(:name, :description, :frequency, :duration)
    return Habit.new(habit_params)
  end

  def assign_habit_to_participants
    for id in session[:new_habit_participants]
      user = User.get_object(id)
      @user_habit = UserHabit.new(user: user, habit: @habit)
      @user_habit.save
      assign_deadlines_to_user_habit
    end
  end

  def assign_deadlines_to_user_habit
    increment = @habit.is_daily? ? 1.day : 1.week
    for i in 1..@habit.duration do
      deadline = @current_date_time + (i * increment)
      UserHabitDeadline.create(user_habit: @user_habit, deadline: deadline)
      i += 1
    end
  end

  def send_invitation_to_participants
    participant_ids = session[:new_habit_participants]
    if participant_ids.count > 1
      habit_invitation = HabitInvitation.create(habit: @habit)
      for id in session[:new_habit_participants]
        UserHabitInvitation.create(user_id: id, habit_invitation: habit_invitation) if id.to_s != current_user.id.to_s
      end
    end
  end

  def set_habit_end_datetime
    if @habit.frequency == 0
      end_datetime = @current_date_time + @habit.duration.days
    elsif @habit.frequency == 1
      end_datetime = @current_date_time + @habit.duration.weeks
    end
    
    @habit.end_datetime = end_datetime
    @habit.save
  end

  def is_habit_refresh?
    return params[:habit_id].present?
  end
end