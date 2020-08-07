# frozen_string_literal: true

$LOAD_PATH << "#{Gem.path[0]}/gems/kramdown-1.8.0/lib"

require 'kramdown'

class MyMemo # :nodoc:
  include Singleton

  def self.install!
    instance.parse
  end

  def list
    width = ruby_snippets.size.to_s.size
    outputs = []
    ruby_snippets.each_with_index do |snippet, index|
      puts_snippet(snippet, index, width, outputs)
    end
    outputs.join("\n")
  end

  def snippet(index)
    ruby_snippets[index][:content][1..-1].join
  end

  def parse
    @root, @errors = Kramdown::Parser::Markdown.parse(File.read('./MyMemo.md'))
    @header = nil
    @root.children.each do |element|
      parse_content(element)
    end
  end

  def ruby_snippets
    @ruby_snippets ||= []
  end

  private

  def puts_snippet(snippet, index, width, outputs)
    follow = snippet[:header] || '-' * (80 - width)
    outputs.push("[#{format("%#{width}d", index)}] #{follow}")
    outputs.push(
      Pry::SyntaxHighlighter.highlight(snippet[:content][1..10].join)
    )
    outputs.push(('.' * 6).gray)
  end

  def parse_content(element)
    content = element.children.map(&:value).join
    if element.type == :p
      return unless content =~ /^ruby/

      ruby_snippets << { header: @header, content: content.lines }
    elsif element.type == :header
      @header = content
    end
    @header = nil if element.type != :header
  end
end
