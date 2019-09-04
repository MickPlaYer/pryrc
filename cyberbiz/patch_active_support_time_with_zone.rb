# frozen_string_literal: true

module ActiveSupport
  class TimeWithZone # :nodoc:
    def inspect
      iso8601
    end
  end
end
