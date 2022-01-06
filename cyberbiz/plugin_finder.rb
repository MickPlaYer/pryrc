# frozen_string_literal: true

$LOAD_PATH << "#{Gem.path[0]}/gems/fuzzy_match-2.1.0/lib"
require 'fuzzy_match'

class PluginFinder # :nodoc:
  def initialize(shop, codes = [])
    @shop = shop
    @codes = codes.sort! { |a, b| -(a <=> b) }
  end

  def add_plugin(code)
    codes = @codes - @shop.plugin_codes
    if codes.bsearch { |c| c <=> code }
      @shop.add_plugin(code)
    else
      suggest(codes, code)
    end
  end

  def del_plugin(code)
    codes = @shop.plugin_codes.sort { |a, b| -(a <=> b) }
    if codes.bsearch { |c| c <=> code }
      @shop.del_plugin(code)
    else
      suggest(codes, code)
    end
  end

  private

  def suggest(codes, code)
    message = "PluginResource code: `#{code}` is not found"
    spell_checker = DidYouMean::SpellChecker.new(dictionary: codes)
    corrects = spell_checker.correct(code)
    if corrects.empty?
      fuzzy_matcher = FuzzyMatch.new(codes)
      corrects = fuzzy_matcher.find_all(code).first(5)
    end
    message += DidYouMean::PlainFormatter.new.message_for(corrects).to_s if corrects.present?
    puts message
  end
end
