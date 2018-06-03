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

  test "create a new habit for a single user, with duration = 1 cycle" do 
    sign_in @user

    #assert that when accessing the root path leads us to the user's profile
    get root_path
    assert_redirected_to user_path(@user)
    follow_redirect!
    assert_template 'users/show'

    # new_habit_path renders habits/set_participants_new
    get new_habit_path
    assert_template 'habits/set_participants_new'

    get build_habit_new_path
    
    assert_difference 'Habit.count', 1 do 
      assert_difference 'UserHabit.count', 1 do
        assert_difference 'UserHabitDeadline.count', 1 do
          post habits_path, params: {habit: {name: "Run", description: "run run run", frequency: 0, duration: 1}}
        end
      end
    end

    assert_redirected_to root_path
    follow_redirect!

    assert_redirected_to user_path(@user)
    follow_redirect!

    assert_template 'users/show'
  end

  test "create a new habit for one user, with duration = 3 cycles" do 
    sign_in @user

    #assert that when accessing the root path leads us to the user's profile
    get root_path
    assert_redirected_to user_path(@user)
    follow_redirect!
    assert_template 'users/show'

    # new_habit_path renders habits/set_participants_new
    get new_habit_path
    assert_template 'habits/set_participants_new'

    get build_habit_new_path
    
    assert_difference 'Habit.count', 1 do 
      assert_difference 'UserHabit.count', 1 do
        assert_difference 'UserHabitDeadline.count', 3 do
          post habits_path, params: {habit: {name: "Run", description: "run run run", frequency: 0, duration: 3}}
        end
      end
    end

    assert_redirected_to root_path
    follow_redirect!

    assert_redirected_to user_path(@user)
    follow_redirect!

    assert_template 'users/show'

  end

  test "create a new habit for two users, with a duration of 5 cycles" do
    sign_in @user
    
    get new_habit_path
    assert 'habits/add_participants'

    post users_search_path, xhr: true, params: {Search_friends: "Moses"}
    
    assert partial: "shared/user_search_results"
    
    assert_difference 'session[:new_habit_participants].count', 1 do
      post habits_add_participant_path(added_participant: @user1.id), xhr: true
    end
    
    get build_habit_new_path
    
    assert_difference 'Habit.count', 1 do 
      assert_difference 'UserHabit.count', 2 do
        assert_difference 'UserHabitDeadline.count', 10 do
          post habits_path, params: {habit: {name: "Run", description: "run run run", frequency: 0, duration: 5}}
        end
      end
    end

    assert_redirected_to root_path
    follow_redirect!

    assert_redirected_to user_path(@user)
    follow_redirect!

    assert_template 'users/show'

  end
end