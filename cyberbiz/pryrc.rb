return if File.exist?('.ignore_my_pryrc') || ENV['IGNORE_MY_PRYRC']

begin
  require 'action_dispatch'
  require_relative '../lib/image_cat'
  require_relative '../lib/string_to_ar'
  require_relative '../lib/table_drawer'
  require_relative './my_memo'
  require_relative './patch_active_support_time_with_zone'
  require_relative './request_explainer'
  require_relative './other_helper'
  require_relative './patch_awesone_print'
  require_relative './plugin_finder'
rescue LoadError, NameError => e
  puts '-' * 40
  puts "#{e.class}: #{e}"
  puts '-' * 40
end

AwesomePrint.defaults = {
  ruby19_syntax: true,
  indent: 2
}
AwesomePrint.pry!

Pry.config.editor = 'vim'

Pry.commands.block_command('edit-string', 'Edit a ruby string') do |var|
  str = target.eval(var)
  file = Tempfile.new('pry-edit-string')
  file.write(str)
  file.close
  run "edit #{file.path}"
  new_str = File.read(file.path)
  target.eval("#{var} = #{new_str.inspect}")
end

Pry.commands.block_command(
  'ar',
  'Compile string to active record',
  keep_retval: true
) do |string|
  StringToAR::Restful.new(string).exec
end

Pry.commands.block_command(
  'rsql',
  'Execute sql by ActiveRecord',
  keep_retval: true
) do |*inputs|
  sql = inputs.take_while { |i| !i.start_with?('-') }.join(' ')
  result = ActiveRecord::Base.connection.execute(sql)
  AwesomePrint::Formatters::StringFormatter.with_limit_size(50) do
    TableDrawer.new(result).draw
  end
  result
end

Pry.commands.block_command('icat', 'Output a image') do |string, options|
  ImageCat.cat(string, file: options.in?(%w[--file -f]))
end

if defined?(PluginFinder)
  Pry.commands.block_command('addpl', 'Add plugin to shop') do |string|
    shop = Pryrc::Reloadable.fetch(:shop)
    codes = KeyValues::Shop::PluginResource.all.map(&:code)
    PluginFinder.new(shop, codes).add_plugin(string.strip)
  end

  Pry.commands.block_command('delpl', 'Remove plugin from shop') do |string|
    shop = Pryrc::Reloadable.fetch(:shop)
    PluginFinder.new(shop).del_plugin(string.strip)
  end
end

if defined?(MyMemo)
  Pry.commands.block_command(
    'list-sn',
    'list ruby snippets from MyMemo'
  ) do
    pry_instance.pager.page(MyMemo.instance.list)
  end

  Pry.commands.block_command(
    'show-sn',
    'show ruby snippets from MyMemo'
  ) do |number|
    number = number.to_s
    next if number.to_i.zero? && number[0] != '0'

    snippet = MyMemo.instance.snippet(number.to_i)
    if snippet
      pry_instance.pager.page(
        Pry::SyntaxHighlighter.highlight(snippet)
      )
    else
      pry_instance.output.puts('No snippet at the index.')
    end
  end

  Pry.commands.block_command(
    'load-sn',
    'load ruby snippets from MyMemo'
  ) do |number|
    number = number.to_s
    next if number.to_i.zero? && number[0] != '0'

    snippet = MyMemo.instance.snippet(number.to_i)
    if snippet
      pry_instance.pager.page(
        Pry::SyntaxHighlighter.highlight(snippet)
      )
      pry_instance.eval_string = snippet
    else
      pry_instance.output.puts('No snippet at the index.')
    end
  end
end

module Pryrc
  module Reloadable # :nodoc:
    def self.init!
      @registers = {}
      @cache = {}
      return unless block_given?

      yield(self)
      start!
    end

    def self.reload!
      @cache = {}
      true
    end

    def self.register!(key, &block)
      @registers[key] = block
      Methods.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{key}
          Reloadable.fetch(:#{key})
        end
      RUBY
    end

    def self.start!
      TOPLEVEL_BINDING.eval('self').extend(Pryrc::Reloadable::Methods)
      ActiveSupport::Reloader.to_prepare { Reloadable.reload! }
    end

    def self.fetch(key)
      @cache[key] ||= @registers[key].call
    end

    def self.registers
      @registers
    end

    def self.cache
      @cache
    end

    module Methods; end # :nodoc:
  end
end

Pryrc::Reloadable.init! do |r|
  r.register!(:shop) { Shop.find_by_name('mick') }
  r.register!(:shipping) { shop.shipping }
  r.register!(:theme) { shop.theme }
  r.register!(:redis) { GlobalRedis.instance }
end

MyMemo.install!
OtherHelper.install!
