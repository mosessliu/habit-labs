require 'test_helper'

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'a Habit with 1 participant, with duration 1 increases UserHabitDeadline by 1' do
    habit_with_duration_1 = habits(:habit_with_duration_1)
    bob = users(:bob)
    
    sign_in(bob)

    assert_difference 'UserHabitDeadline.count', 1 do
      create_habit(habit_with_duration_1)
    end

  end

  test 'a Habit with 2 participants, with duration 1 increases UserHabitDeadline by 2' do
    bob = users(:bob)
    kate = users(:kate)
    habit_with_duration_1 = habits(:habit_with_duration_1)

    sign_in(bob)
    assert_difference 'UserHabitDeadline.count', 2 do
      create_habit_with_invites(habit_with_duration_1, [kate])
    end
  end

  test 'a Habit with 2 participants, with duration 3 increases UserHabitDeadline by 6' do
    bob = users(:bob)
    kate = users(:kate)
    habit_with_duration_3 = habits(:habit_with_duration_3)

    sign_in(bob)
    assert_difference 'UserHabitDeadline.count', 6 do
      create_habit_with_invites(habit_with_duration_3, [kate])
    end
  end

  test 'user owns one more habit when user creates another habit' do
  end

  test 'habit must be finished to refresh it' do
    habit = habits(:habit1)
    bob = users(:bob)

    sign_in(bob)
    create_habit(habit)
    get user_path(bob)
    assert_template 'users/show'

    # assert that user is redirected to root path if habit is not finished
    get refresh_habit_path(habit_id: habit)
    assert_redirected_to root_path
  end

  test 'habit must belong to user to refresh it' do
    bob = users(:bob)
    kate = users(:kate)
    habit = habits(:habit1)

    sign_in(bob)
    create_habit(habit)
    force_finish_last_created_habit!(bob)
    sign_out(bob)
    bobs_habit = bob.habits.last

    sign_in(kate)
    get refresh_habit_path(habit_id: bobs_habit)
    assert_redirected_to root_path
  end

  test 'habit must belong to user to build_refresh it' do
    bob = users(:bob)
    kate = users(:kate)
    habit = habits(:habit1)

    sign_in(bob)
    create_habit(habit)
    force_finish_last_created_habit!(bob)
    sign_out(bob)
    bobs_habit = bob.habits.last

    sign_in(kate)
    post build_habit_refresh_path(habit_id: bobs_habit)
    assert_redirected_to root_path

  end

  test 'habit must be finished to untrack it' do
    habit = habits(:habit_with_duration_3)
    bob = users(:bob)

    sign_in(bob)
    create_habit(habit)

    bobs_habit = bob.habits.last

    assert_no_difference 'bob.habits.count' do
      post untrack_finished_habit_path(habit_id: bobs_habit.id), xhr: true
    end
  end

  test 'user must own habit to untrack it' do 
    habit = habits(:habit_with_duration_3)
    bob = users(:bob)
    kate = users(:kate)

    sign_in(bob)
    create_habit(habit)
    bobs_habit = bob.habits.last
    force_finish_last_created_habit!(bob)
    
    # habit belongs to bob, so kate can't unfollow the habit
    sign_out(bob)
    sign_in(kate)

    assert_no_difference 'kate.habits.count' do
      assert_no_difference 'bob.habits.count' do
        post untrack_finished_habit_path(habit_id: bobs_habit), xhr: true
      end
    end
  end

end