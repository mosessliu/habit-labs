class UsersController < ApplicationController
  before_action :mark_finished_habits, only: [:show]
  
  def show
    @invited_habit_ids = []
    current_user.habit_invitations.each {|invite| @invited_habit_ids << invite.habit_id}
    
    # dont display habits that are actually still a notification
    @active_habits = []
    @finished_habits =[]
    current_user.habits.each do |habit|
      if not @invited_habit_ids.include?(habit.id)
        if habit.finished
          @finished_habits << habit
        else
          @active_habits << habit
        end
      end
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
  def mark_finished_habits
    if params[:id].to_s == current_user.id.to_s
      current_datetime = DateTime.current
      for habit in current_user.habits
        if habit.end_datetime < current_datetime
          habit.finished = true
          habit.save
        end
      end
    end
  end
end