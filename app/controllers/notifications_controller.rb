class NotificationsController < ApplicationController

  def notifications
    @pending_habits = []
    current_user.habit_invitations.each do |inv|
      @pending_habits.push(inv.habit)
    end
  end

  def show_habit_invitation
    @habit = Habit.find(params[:habit_id])
    @user_habit = UserHabit.where(user: current_user, habit: @habit).first
  end

end