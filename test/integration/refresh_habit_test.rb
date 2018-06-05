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
    
    @finished_habit = Habit.new(
      name: "Test Habit",
      description: "Test Habit",
      duration: 2,
      frequency: 0
    )

  end

  test 'refresh a finished habit' do 
    prep
    finished_habit = @user.habits.last

    get refresh_habit_path(habit_id: finished_habit)
    assert_template 'habits/set_participants_refresh'

    post build_habit_refresh_path(habit_id: finished_habit)
    assert_template 'habits/build_habit_refresh'

    assert_difference 'Habit.count', 1 do
      post create_refreshed_habit_path(habit: {
        name: finished_habit.name + " refresh", 
        description: finished_habit.description,
        frequency: finished_habit.frequency,
        duration: finished_habit.duration
      })
    end

    assert_redirected_to root_path
    follow_redirect!
    assert_redirected_to user_path(@user)
    follow_redirect!

    refreshed_habit = @user.habits.last

    assert_select("a[href=?]", 
      habit_path(refreshed_habit), 
      text: finished_habit.name + " refresh")

  end

  test 'start refreshing a habit, add a friend participant, advance through participant selection, but go back to participant selection' do
    prep
    finished_habit = @user.habits.last

    get refresh_habit_path(habit_id: finished_habit)
    assert_template 'habits/set_participants_refresh'

    post habits_add_participant_path(added_participant: @user1.id), xhr: true

    post build_habit_refresh_path(habit_id: finished_habit)
    assert_template 'habits/build_habit_refresh'

    get back_to_edit_participants_path(habit_id: finished_habit)
    assert_template 'habits/set_participants_refresh'

    for user_id in session[:new_habit_participants]
      assert user_id.to_s == @user.id.to_s || user_id.to_s == @user1.id.to_s
    end

    assert session[:new_habit_participants].count == 2
  end

  test 'start refreshing a habit, advance through participant selection, go back to participant selection, advance through participant selection' do
    prep
    finished_habit = @user.habits.last

    get refresh_habit_path(habit_id: finished_habit)
    assert_template 'habits/set_participants_refresh'

    post build_habit_refresh_path(habit_id: finished_habit)
    assert_template 'habits/build_habit_refresh'

    get back_to_edit_participants_path(habit_id: finished_habit)
    assert_template 'habits/set_participants_refresh'

    post build_habit_refresh_path(habit_id: finished_habit)
    assert_template 'habits/build_habit_refresh'

    assert_difference 'Habit.count', 1 do
      post create_refreshed_habit_path(habit: {
        name: finished_habit.name + " refresh", 
        description: finished_habit.description,
        frequency: finished_habit.frequency,
        duration: finished_habit.duration
      })
    end

    assert_redirected_to root_path
    follow_redirect!
    assert_redirected_to user_path(@user)
    follow_redirect!

    refreshed_habit = @user.habits.last

    assert_select("a[href=?]", 
      habit_path(refreshed_habit), 
      text: finished_habit.name + " refresh"
    )

  end

  test 'start refreshing a habit, add a friend, go to home page, build a new habit, assert that participants are reset' do
    prep
    finished_habit = @user.habits.last

    get refresh_habit_path(habit_id: finished_habit)
    assert_template 'habits/set_participants_refresh'

    assert_difference 'session[:new_habit_participants].count', 1 do
      post habits_add_participant_path(added_participant: @user1), xhr: true
    end

    get root_path
    assert_redirected_to user_path(@user)
    follow_redirect!
    assert_template 'users/show'

    get new_habit_path
    assert_template 'habits/set_participants_new'
    assert session[:new_habit_participants].count == 1
    assert session[:new_habit_participants].first.to_s == @user.id.to_s
  end

  private 
  def prep
    sign_in @user
    create_habit(@finished_habit)
    force_finish_last_created_habit!(@user)

    finished_habit = @user.habits.last
    assert finished_habit.finished

  end

end

