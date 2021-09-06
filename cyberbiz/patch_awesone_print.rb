# frozen_string_literal: true

require 'awesome_print'

module AwesomePrint
  class Formatter # :nodoc:
    def awesome_string(string)
      Formatters::StringFormatter.new(string, @options).format
    end
  end

  module PatchInspectorInitialize # :nodoc:
    def initialize(options = {})
      super
      @options[:color][:integer] = :blue
    end
  end

  module Formatters
    class StringFormatter # :nodoc:
      mattr_accessor :limit_size
      LIMT_SIZE = 256
      SEPARATOR = '...'.freeze
      QUOTE = '"'.freeze
      COLOR = :yellow

      def self.with_limit_size(size)
        before = limit_size
        self.limit_size = size
        yield
      ensure
        self.limit_size = before
      end

      def initialize(string, options)
        @options = options
        limit_size = self.class.limit_size || LIMT_SIZE
        if string.size > limit_size
          @string = string.first(limit_size - SEPARATOR.size)
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

if AwesomePrint.version == '1.9.2'
  AwesomePrint::Formatter::CORE_FORMATTERS.push(:string)
else
  AwesomePrint::Formatter::CORE.push(:string)
end
AwesomePrint::Inspector.send(:prepend, AwesomePrint::PatchInspectorInitialize)
