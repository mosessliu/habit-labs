require 'test_helper'

class CreateHabitTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = User.create(
      username: "John", 
      email: "john@example.com", 
      first_name: "John",
      last_name: "Liu",
      password: "password",
    )

    @user1 = User.create(
      username: "Moses", 
      email: "Moses@example.com", 
      first_name: "Moses",
      last_name: "Liu",
      password: "password",
    )
  end

  test 'refresh an expired habit' do
    
  end

end
