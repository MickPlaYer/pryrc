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

    def params(hash)
      ActionController::Parameters.new(hash)
    end

    def ruby_prof(&block)
      require('ruby-prof')
      result = RubyProf.profile(&block)
      printer = RubyProf::MultiPrinter.new(result, %i[flat graph_html stack])
      printer.print(path: '/tmp/', profile: 'pry_ruby_prof')
    end
  end

  def self.install!
    TOPLEVEL_BINDING.eval('self').extend(OtherHelper::Methods)
    TOPLEVEL_BINDING.eval('app').host = "mick.#{ENV['MYCYBERBIZ']}"
  end
end
