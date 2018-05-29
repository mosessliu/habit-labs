class HabitsController < ApplicationController

  def new
    set_default_participants
    render 'habits/add_participants'
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
      @current_date_time = DateTime.current
      assign_habit_to_participants
      send_invitation_to_participants
      set_habit_end_datetime
      redirect_to root_path
    else
      render 'habits/build_habit.html'
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

  private
  def set_default_participants
    session[:new_habit_participants] = [current_user.id]
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
    if @habit.frequency == 0 #daily case
      i = 1
      while i <= @habit.duration
        deadline = @current_date_time + i.days
        UserHabitDeadline.create(user_habit: @user_habit, deadline: deadline)
        i += 1
      end
    elsif @habit.frequency == 1 #weekly case
      i = 1
      while i <= @habit.duration
        deadline = @current_date_time + i.weeks
        UserHabitDeadline.create(user_habit: @user_habit, deadline: deadline)
        i += 1
      end
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

end