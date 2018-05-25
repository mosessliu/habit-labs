class UsersController < ApplicationController
  
  def show
  end

  def search
    results = User.search(params[:Search_friends])
    respond_to do |f|
      
    end
  end

end