# frozen_string_literal: true

module RequestExplainer
  class ParamsPattern # :nodoc:
    def initialize(result)
      result[:params] ||= []
      @result = result
    end

    def execute(line)
      return unless (match = line.match(/Parameters: ({.*})/))

      @result[:params].push(match[1])
    end
  end
end
