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

class Integer
  def weeks
    self.days * 7
  end
  alias :week :weeks

  def days
    self * 24 * 60 * 60
  end
  alias :day :days
end

