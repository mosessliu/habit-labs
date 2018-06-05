require 'test_helper'

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @bob = users(:bob)
    @kate = users(:kate)
    @moses = users(:moses)
    @habit = habits(:habit1)
  end

  test 'last person to accept a habit also destroys the related habitinvitation' do
    sign_in(@bob)
    create_habit_with_invites(@habit, [@kate, @moses])
    habit = Habit.last #the last created habit

    assert @bob.habit_invitations.count == 0
    assert @kate.habit_invitations.count == 1
    assert @moses.habit_invitations.count == 1

    sign_out(@bob)
    
    sign_in(@kate)
    assert_difference 'UserHabitInvitation.count', -1 do
      accept_habit(habit)
    end
    assert @kate.habit_invitations.count == 0
    sign_out(@kate)
    
    sign_in(@moses)
    assert_difference 'UserHabitInvitation.count', -1 do
      assert_difference 'HabitInvitation.count', -1 do
        accept_habit(habit)
      end
    end
    assert @moses.habit_invitations.count == 0

  end

  

end