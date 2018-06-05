require 'test_helper'

class DeleteFinishedHabitTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'delete a finished habit, owned by 1 user' do
    bob = users(:bob)
    habit = habits(:habit_with_duration_3)

    sign_in(bob)
    create_habit(habit)

    #reassign habit variable
    habit = bob.habits.last

    force_finish_last_created_habit!(bob)

    assert bob.habits.count == 1
    assert bob.habits.last.finished

    assert_difference 'bob.habits.count', -1 do 

      # :habit_with_duration_3 has a duration of 3
      assert_difference 'UserHabitDeadline.count', -3 do
        
        # habit is removed from database because nobody owns it anymore
        assert_difference 'Habit.count', -1 do
          post untrack_finished_habit_path(habit_id: habit.id), xhr: true
        end
      end
    end
  end

  test 'delete a finished habit, owned by 2 users' do
    bob = users(:bob)
    kate = users(:kate)
    habit = habits(:habit_with_duration_3)

    sign_in(bob)
    get new_habit_path
    post habits_add_participant_path(added_participant: kate), xhr: true
    assert session[:new_habit_participants].count == 2
    
    for id in session[:new_habit_participants]
      assert id.to_s == kate.id.to_s || id.to_s == bob.id.to_s
    end
    
    create_habit(habit, true)
    assert bob.habits.count == 1
    assert kate.habits.count == 1
  
    force_finish_last_created_habit!(bob)
    assert bob.habits.last.finished
    assert kate.habits.last.finished

    habit = bob.habits.last

    assert_difference 'bob.habits.count', -1 do 
      # there should be 3 less deadlines when the the user untracks this habit
      assert_difference 'UserHabitDeadline.count', -3 do
        # habit is not removed yet from database because kate still tracks it
        assert_no_difference 'Habit.count' do
          post untrack_finished_habit_path(habit_id: habit.id), xhr: true
        end
      end
    end

    sign_out(bob)
    sign_in(kate)

    assert kate.habits.last == habit
    
    assert_difference 'kate.habits.count', -1 do 
      assert_difference 'UserHabitDeadline.count', -3 do
        # habit is removed from database because nobody owns it anymore
        assert_difference 'Habit.count', -1 do
          post untrack_finished_habit_path(habit_id: habit.id), xhr: true
        end
      end
    end

    assert_select "a[href=?]", habit_path(habit), false

  end
  
end

