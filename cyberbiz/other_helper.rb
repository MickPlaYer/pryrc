# frozen_string_literal: true

module OtherHelper # :nodoc:
  LetsRoll = Class.new(StandardError)

  module Methods # :nodoc:
    def with_rollback
      result = nil
      ActiveRecord::Base.transaction do
        result = yield
        raise LetsRoll
      end
    rescue LetsRoll
      result
    end
  end

  def self.install!
    TOPLEVEL_BINDING.eval('self').extend(OtherHelper::Methods)
  end
end
