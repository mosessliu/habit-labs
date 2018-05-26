class UsersController < ApplicationController
  
  def show
  end

  def search
    param = params[:Search_friends]
    @results = User.search(param)
    if @results.count == 0 && param.present?
      flash.now[:danger] = "No results matched query #{params[:Search_friends]}"
    end

    respond_to do |format|
      format.js {render partial: 'shared/user_search_results.js'}
    end
  end

end