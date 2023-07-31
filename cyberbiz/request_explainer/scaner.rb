# frozen_string_literal: true

require_relative './patterns'

module RequestExplainer
  class Scaner # :nodoc:
    CanNotHandleItError = Class.new(StandardError)

    def initialize(logs)
      @logs = case logs
              when String
                logs.lines
              when Array
                logs
              else
                raise CanNotHandleItError
              end
    end

    def execute
      result = {}
      patterns = Patterns.build_all(result)
      @logs.each do |log|
        patterns.each do |pattern|
          pattern.execute(log)
        end
      end
      result
    end

    def inspect
      "#<#{self.class}>"
    end
  end
end
