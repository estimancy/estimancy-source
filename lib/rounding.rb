# Use require "rounding"  to use this function
class Numeric
  # round a given number to the nearest step
  def round_up_by_step(increment)
    (self / increment).ceil * increment
  end
end