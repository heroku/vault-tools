class Time
  def last_month
    (self.to_datetime << 1).to_time
  end

  def next_month
    (self.to_datetime >> 1).to_time
  end

  def tomorrow
    (self.to_datetime + 1).to_time
  end

  def yesterday
    (self.to_datetime - 1).to_time
  end
end

class Fixnum
  def weeks

  end

  def days
    self * 24 * 60 * 60
  end
  alias :day, :days
end

