# frozen_string_literal: true

module RequestExplainer
  class FindUserPattern # :nodoc:
    def initialize(result)
      result[:user] ||= []
      @result = result
    end

    def execute(line)
      regexp =
        /SELECT `users`.* FROM `users` WHERE `users`.`id` = (\d+) LIMIT 1/
      return unless (match = line.match(regexp))

      @result[:user].push(match[1])
    end
  end
end
