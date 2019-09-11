# frozen_string_literal: true

module AwesomePrint
  class Formatter # :nodoc:
    def awesome_string(string)
      Formatters::StringFormatter.new(string, @options).format
    end
  end

  module Formatters
    class StringFormatter # :nodoc:
      LIMT_SIZE = 256
      SEPARATOR = '...'.freeze

      def initialize(string, options)
        @options = options
        if string.size > LIMT_SIZE
          @string = string.first(LIMT_SIZE - SEPARATOR.size)
          @end = SEPARATOR
        else
          @string = string
          @end = ''.freeze
        end
      end

      def format
        "\"#{@string}".send(@options[:color][:string]) +
          @end.yellow +
          '"'.send(@options[:color][:string])
      end
    end
  end
end

AwesomePrint::Formatter::CORE.push(:string)
