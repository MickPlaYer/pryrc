# frozen_string_literal: true

AwesomePrint::Formatter::CORE.push(:string)

module AwesomePrint
  class Formatter # :nodoc:
    def awesome_string(string)
      Formatters::StringFormatter.new(string, @inspector).format
    end
  end

  module Formatters
    class StringFormatter < SimpleFormatter # :nodoc:
      LIMT_SIZE = 256
      SEPARATOR = '...'.freeze

      def initialize(string, inspector)
        if string.size > LIMT_SIZE
          @string = string.first(LIMT_SIZE - SEPARATOR.size)
          @end = SEPARATOR
        else
          @string = string
          @end = ''.freeze
        end
        super(@string, :string, inspector)
      end

      def format
        colorize("\"#{@string}", :string) +
          @end.yellow +
          colorize('"'.freeze, :string)
      end
    end
  end
end
