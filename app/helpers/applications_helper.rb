module ApplicationsHelper
  def sign(value)
    if value > 0
      "+#{value}"
    elsif value < 0
      "-#{value}"
    else
      value
    end
  end
end
