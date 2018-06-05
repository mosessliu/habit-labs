ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  
  def force_finish_last_created_habit!(user)
    habit = user.habits.last
    habit.end_datetime = DateTime.current - 1000
    habit.save

    # show user path updates habit finished status
    get user_path(user)
  end

  def force_finish_habit(habit)
    habit.end_datetime = DateTime.current - 1000
    habit.save
    get user_path()
  end

  #requires logged in user, 
  #gets new_habit_path to assign participant, 
  #then posts the new habit
  
  def create_habit(habit, participants_already_assigned = false)
    if not participants_already_assigned
      get new_habit_path
    end
    post habits_path(habit: {
      name: habit.name, 
      description: habit.description,
      frequency: habit.frequency,
      duration: habit.duration
    })
  end

end
