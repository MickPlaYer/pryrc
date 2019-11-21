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
      QUOTE = '"'.freeze
      COLOR = :yellow

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
        quote = QUOTE.send(COLOR)
        quote +
          @string.inspect[1...-1].send(@options[:color][:string]) +
          @end.send(COLOR) +
          quote
      end
    end
  end
end

AwesomePrint::Formatter::CORE.push(:string)
