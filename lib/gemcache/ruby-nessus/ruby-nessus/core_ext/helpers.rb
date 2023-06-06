# frozen_string_literal: true

class Integer
  # Return false if the integer does NOT equal zero
  # @return [Boolean]
  #   Return true is count does NOT equal zero
  # @example
  #   host.event_count.blank? #=> false
  def blank?
    return true if zero?

    false
  end

  # Return a severity integer in words.
  # @return [String]
  #   Return a severity integer in words.
  # @example
  #   event.severity.in_words #=> "High Severity"
  def in_words
    case self
    when 0
      'Informational Severity'
    when 1
      'Low Severity'
    when 2
      'Medium Severity'
    when 3
      'High Severity'
    when 4
      'Critical Severity'
    end
  end

  # Return True if the given severity is critical
  # @return [Boolean]
  #   Return True if the given severity is critical
  # @example
  #   host.severity.critical? #=> true
  def critical?
    self == 4
  end

  # Return True if the given severity is high
  # @return [Boolean]
  #   Return True if the given severity is high
  # @example
  #   host.severity.high? #=> true
  def high?
    self == 3
  end

  # Return True if the given severity is medium
  # @return [Boolean]
  #   Return True if the given severity is medium
  # @example
  #   host.severity.medium? #=> true
  def medium?
    self == 2
  end

  # Return True if the given severity is low
  # @return [Boolean]
  #   Return True if the given severity is low
  # @example
  #   host.severity.low? #=> true
  def low?
    self >= 1
  end
end

class String
  # Return True if the given string is blank?
  # @return [Boolean]
  #   Return True if the given string is blank?
  # @example
  #   host.hostname.blank? #=> false
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end
end

class DateTime
  def pretty
    strftime('%A %B %d, %Y %I:%M:%S %p')
  end
end
