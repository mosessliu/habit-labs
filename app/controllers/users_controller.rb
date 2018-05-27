class UsersController < ApplicationController
  
  def show
  end

  def search
    param = params[:Search_friends]
    if param.blank?
      @results = nil
    else
      @results = User.search(param, current_user.id)
      if @results.count == 0
        flash.now[:danger] = "No results matched query '#{params[:Search_friends]}'"
      end
    end

    respond_to do |format|
      format.js {render partial: 'shared/user_search_results.js'}
    end
  end

end