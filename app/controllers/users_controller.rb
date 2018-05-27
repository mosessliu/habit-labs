class UsersController < ApplicationController
  before_action :delete_expired_habits, only: [:show]
  
  def show

    #dont display habits that are actually still a notification
    @active_habits = current_user.habits.select do |habit| 
      current_user.habit_invitations.where(habit_id: habit.id).count == 0
    end
  end

  def search
    param = params[:Search_friends]
    if param.blank?
      @results = nil
    else
      @results = User.search(param, current_user.id)
      already_selected_users = session[:new_habit_participants]
      @results = @results.select {|user| !already_selected_users.include?(user.id.to_s)}
      if @results.count == 0
        flash.now[:danger] = "No results matched query '#{params[:Search_friends]}'"
      end
    end

    respond_to do |format|
      format.js {render partial: 'shared/user_search_results.js'}
    end
  end

  private
  def delete_expired_habits
    if params[:id].to_s == current_user.id.to_s
      current_datetime = DateTime.current
      for habit in current_user.habits
        if habit.end_datetime < current_datetime
          puts habit
          habit.destroy!
        end
      end
    end
  end

end