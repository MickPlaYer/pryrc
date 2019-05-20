# frozen_string_literal: true

require 'active_support/all'

module StringToAR
  class Restful # :nodoc:
    def initialize(string)
      @string = string.to_s.strip
    end

    def exec
      words = @string.split('/')
      words.shift if words.first.blank?
      record = nil
      words.each_slice(2) do |record_name, key|
        next if record_name.nil? && key.nil?

        scope = find_scope(record, record_name)
        record = find_record(scope, key)
      end
      record
    end

    private

    def fuzzy_call(target, message)
      if target.respond_to?(message)
        [true, target.send(message)]
      elsif target.respond_to?(message.singularize)
        [true, target.send(message.singularize)]
      elsif target.respond_to?(message.pluralize)
        [true, target.send(message.pluralize)]
      end
    end

    def find_scope(record, record_name)
      return record_name.singularize.classify.constantize if record.nil?

      respond, result = fuzzy_call(record, record_name)
      return result if respond

      if record.respond_to?(:first)
        respond, result = fuzzy_call(record.first, record_name)
        return result if respond
      end

      raise NoMethodError, "undefined method `#{record_name}' for #{record}"
    end

    def find_record(scope, key)
      id = key.to_i
      return scope.find(id) if id > 0

      terms = key.to_s.strip.split(':')
      terms.shift if terms.first.blank?
      chain_condictions(scope, terms)
    end

    def chain_condictions(scope, terms)
      terms.each_slice(2) do |attribute, value|
        next if attribute.nil? && value.nil?

        scope = if value.blank?
                  scope.send(attribute)
                else
                  scope.where(attribute => value)
                end
      end
      scope
    end
  end
end

class String # :nodoc:
  def to_ar
    StringToAR::Restful.new(self).exec
  end
end
