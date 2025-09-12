# frozen_string_literal: true

require 'amazing_print'

module AmazingPrint
  class Formatter # :nodoc:
    def awesome_string(string)
      Formatters::StringFormatter.new(string, @inspector).format
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
      attr_reader :options
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

      def initialize(string, inspector)
        @options = inspector.options
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
        quote = AmazingPrint::Colors.public_send(COLOR, QUOTE)
        content = AmazingPrint::Colors.public_send(
          @options[:color][:string],
          @string.inspect[1...-1],
        )
        quote +
          content +
          AmazingPrint::Colors.public_send(COLOR, @end) +
          quote
      end
    end
  end
end

AmazingPrint::Formatter::CORE_FORMATTERS =
  AmazingPrint::Formatter::CORE_FORMATTERS.dup.push(:string)
AmazingPrint::Inspector.send(:prepend, AmazingPrint::PatchInspectorInitialize)
