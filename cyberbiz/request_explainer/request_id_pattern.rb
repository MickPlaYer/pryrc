# frozen_string_literal: true

module RequestExplainer
  class RequestIdPattern # :nodoc:
    def initialize(result)
      result[:request_id] ||= []
      @result = result
    end

    def execute(line)
      return unless (match = line.match(/\[([0-9a-f]{32})\]/))

      @result[:request_id].push(match[1])
    end
  end
end
