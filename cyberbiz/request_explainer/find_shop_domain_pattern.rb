# frozen_string_literal: true

module RequestExplainer
  class FindShopDomainPattern # :nodoc:
    def initialize(result)
      result[:shop_domain] ||= []
      @result = result
    end

    def execute(line)
      regexp = /
        SELECT\s`shop_domains`\.\*\sFROM\s`shop_domains`\s
        WHERE\s`shop_domains`\.`host`\s=\s'(.+)'\sLIMIT\s1
      /x
      return unless (match = line.match(regexp))

      @result[:shop_domain].push(match[1])
    end
  end
end
