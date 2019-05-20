# frozen_string_literal: true

require 'net/http'
require 'base64'

module ImageCat # :nodoc:
  class << self
    def cat!
      @cat = true
    end

    def cat?
      !@cat.nil?
    end

    def cat(string, name: nil, file: false)
      cat!
      return from_path(string, name: name) if File.exist?(string) || file

      from_uri(string, name: name)
    rescue URI::InvalidURIError, NoMethodError
      from_base64(string, name: name)
    ensure
      @cat = false
    end

    def from_path(file_path, name: nil)
      raw = File.read file_path
      name ||= file_path
      size ||= raw.bytesize
      encode_and_concat_data(raw, name: name, size: size)
    end

    def from_file(file, name: nil)
      raw = file.read
      name ||= File.basename file
      size = raw.bytesize
      encode_and_concat_data(raw, name: name, size: size)
    end

    def from_uri(uri, name: nil)
      uri = URI.parse(uri) unless uri.is_a? URI
      raw = Net::HTTP.get(uri)
      name ||= File.basename(uri.path)
      size = raw.bytesize
      encode_and_concat_data(raw, name: name, size: size)
    end

    def from_base64(content, name: nil, size: nil)
      name = Base64.strict_encode64 name if name
      concat_data(content, name: name, size: size)
    end

    private

    def encode_and_concat_data(raw, name: nil, size: nil)
      name = Base64.strict_encode64 name
      content = Base64.strict_encode64 raw
      concat_data(content, name: name, size: size)
    end

    def concat_data(content, name: nil, size: nil)
      name ||= Base64.strict_encode64 "ImageCat-#{Time.now.to_i}"
      size = size.nil? ? '' : "size=#{size};"
      result = "\e]1337;File=name=#{name};#{size}inline=1:#{content}\a\n"
      return puts result if cat?
      result
    end
  end
end
