# frozen_string_literal: true

module RequestExplainer
  class ControllerPattern # :nodoc:
    def initialize(result)
      result[:controller] ||= []
      @result = result
    end

    def execute(line)
      return unless (match = line.match(/Processing by ([\w:#]+)/))

      @result[:controller].push(match[1])
    end
  end
end
