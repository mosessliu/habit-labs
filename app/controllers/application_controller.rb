class ApplicationController < ActionController::Base
  before_action :authenticate_user!, unless: :welcome_controller?
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :first_name, :last_name])
  end

  def welcome_controller?
    return params[:controller] == "welcome"
  end

end
