class UserHabitDeadlinesController < ApplicationController
  
  def complete_habit
    habit = Habit.find(params[:habit_id])

    #params passed into to ajax response
    @habit = habit
    @user_habit = UserHabit.where(user: current_user, habit: habit).first
    @limit = habit.frequency == 0 ? DateTime.current + 1.days : DateTime.current + 1.weeks 
    
    next_user_habit_deadline = UserHabitDeadline.get_next_user_habit_deadline(@user_habit)

    if next_user_habit_deadline.blank?
      flash[:danger] = "You cannot complete an expired habit"
      redirect_to root
      return
    end

    next_user_habit_deadline.completed = true
    next_user_habit_deadline.save

    respond_to do |format|
      format.js {render partial: 'user_habit_deadlines/respond_to_complete_habit.js'}
    end
  end
end