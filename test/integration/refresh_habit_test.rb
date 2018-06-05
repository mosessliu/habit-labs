require 'test_helper'

class CreateHabitTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @moses = users(:moses)

    @kate = users(:kate)

    @finished_habit = habits(:habit1)

  end

  test 'refresh a finished habit' do 
    prep
    finished_habit = @moses.habits.last

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
    assert_redirected_to user_path(@moses)
    follow_redirect!

    refreshed_habit = @moses.habits.last

    assert_select("a[href=?]", 
      habit_path(refreshed_habit), 
      text: finished_habit.name + " refresh")

  end

  test 'start refreshing a habit, add a friend participant, advance through participant selection, but go back to participant selection' do
    prep
    finished_habit = @moses.habits.last

    get refresh_habit_path(habit_id: finished_habit)
    assert_template 'habits/set_participants_refresh'

    post habits_add_participant_path(added_participant: @kate), xhr: true
    for user_id in session[:new_habit_participants]
      assert user_id.to_s == @moses.id.to_s || user_id.to_s == @kate.id.to_s
    end

    assert session[:new_habit_participants].count == 2
  end

  test 'start refreshing a habit, advance through participant selection, go back to participant selection, advance through participant selection' do
    prep
    finished_habit = @moses.habits.last

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
    assert_redirected_to user_path(@moses)
    follow_redirect!

    refreshed_habit = @moses.habits.last

    assert_select("a[href=?]", 
      habit_path(refreshed_habit), 
      text: finished_habit.name + " refresh"
    )

  end

  test 'start refreshing a habit, add a friend, go to home page, build a new habit, assert that participants are reset' do
    prep
    finished_habit = @moses.habits.last

    get refresh_habit_path(habit_id: finished_habit)
    assert_template 'habits/set_participants_refresh'

    assert_difference 'session[:new_habit_participants].count', 1 do
      post habits_add_participant_path(added_participant: @kate
        ), xhr: true
    end

    get root_path
    assert_redirected_to user_path(@moses)
    follow_redirect!
    assert_template 'users/show'

    get new_habit_path
    assert_template 'habits/set_participants_new'
    assert session[:new_habit_participants].count == 1
    assert session[:new_habit_participants].first.to_s == @moses.id.to_s
  end

  test 'refresh a habit with 3 participants (2 invites), make sure notifications are sent out' do

  end

  private 
  def prep
    sign_in @moses
    create_habit(@finished_habit)
    force_finish_last_created_habit!(@moses)

    finished_habit = @moses.habits.last
    assert finished_habit.finished

  end

end

