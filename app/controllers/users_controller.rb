class UsersController < ApplicationController
  before_action :delete_expired_habits, only: [:show]
  
  def show
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