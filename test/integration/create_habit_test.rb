require 'test_helper'

class CreateHabitTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "create a new habit for 1 user, with duration = 1 cycle" do 
    moses = users(:moses)
    habit_with_duration_1 = habits(:habit_with_duration_1)

    sign_in(moses)

    get new_habit_path
    assert_template 'habits/set_participants_new'
    get build_habit_new_path
    assert_template 'habits/build_habit_new'

    assert_difference 'Habit.count', 1 do
      assert_difference 'moses.habits.count', 1 do
        create_habit(habit_with_duration_1)
      end
    end

    habit = moses.habits.last

    assert moses.user_habits.last.user_habit_deadlines.count == 1

    assert_redirected_to root_path
    follow_redirect!
    assert_redirected_to user_path(moses)
    follow_redirect!

    assert_template 'users/show'
    assert_select 'a[href=?]', habit_path(habit), text: habit.name

  end

  test "create a new habit for 1 user, with duration = 3 cycles" do 
    moses = users(:moses)
    habit_with_duration_3 = habits(:habit_with_duration_3)

    sign_in(moses)

    get new_habit_path
    assert_template 'habits/set_participants_new'
    get build_habit_new_path
    assert_template 'habits/build_habit_new'

    assert_difference 'Habit.count', 1 do
      assert_difference 'moses.habits.count', 1 do
        create_habit(habit_with_duration_3)
      end
    end

    habit = moses.habits.last

    assert moses.user_habits.last.user_habit_deadlines.count == 3

    assert_redirected_to root_path
    follow_redirect!
    assert_redirected_to user_path(moses)
    follow_redirect!

    assert_template 'users/show'
    assert_select 'a[href=?]', habit_path(habit), text: habit.name
  end

  test "create a new habit for 3 users, with a duration of 3 cycles" do
    moses = users(:moses)
    kate = users(:kate)
    bob = users(:bob)
    habit_with_duration_3 = habits(:habit_with_duration_3)

    sign_in(moses)

    get new_habit_path
    assert_template 'habits/set_participants_new'

    add_participant_to_habit(kate)
    add_participant_to_habit(bob)

    get build_habit_new_path
    assert_template 'habits/build_habit_new'
    assert session[:new_habit_participants].count == 3

    # assert the correct number of userhabitdeadlines are being created

    assert_difference 'Habit.count', 1 do
      assert_difference 'moses.habits.count', 1 do
        assert_difference 'UserHabitDeadline.count', 9 do
          create_habit(habit_with_duration_3, true)
        end
      end
    end

    assert moses.user_habits.last.user_habit_deadlines.count == 3

    habit = moses.habits.last
    assert_redirected_to root_path
    follow_redirect!
    assert_redirected_to user_path(moses)
    follow_redirect!

    assert_template 'users/show'
    assert_select 'a[href=?]', habit_path(habit), text: habit.name

    sign_out(moses)

    habit = Habit.last
    
    # assert invited participants received invitation
    
    sign_in(kate)
    get notifications_path
    assert_template 'notifications/notifications'
    assert_select 'a[href=?]', show_habit_invitation_path(habit_id: habit), text: habit.name
    assert kate.habit_invitations.count == 1
    sign_out(kate)

    sign_in(bob)
    get notifications_path
    assert_template 'notifications/notifications'
    assert_select 'a[href=?]', show_habit_invitation_path(habit_id: habit), text: habit.name
    assert bob.habit_invitations.count == 1
    sign_out(bob)

  end
end