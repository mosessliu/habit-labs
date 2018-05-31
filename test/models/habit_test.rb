require 'test_helper'

class HabitTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def setup
    @habit = Habit.new(name: "Run", description: "run run run", duration: 1, frequency: 1)
  end


  test "habit returns correct frequency" do
    assert @habit.is_weekly?
  end

end
