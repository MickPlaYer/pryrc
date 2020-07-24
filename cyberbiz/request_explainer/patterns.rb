# frozen_string_literal: true

require_relative './request_id_pattern'
require_relative './controller_pattern'
require_relative './params_pattern'
require_relative './find_shop_domain_pattern'
require_relative './find_user_pattern'

module RequestExplainer
  class Patterns # :nodoc:
    PATTERNS = [
      RequestIdPattern,
      ParamsPattern,
      ControllerPattern,
      FindShopDomainPattern,
      FindUserPattern
    ].freeze

    def self.build_all(*args)
      PATTERNS.map { |pattern| pattern.new(*args) }
    end
  end
end
