# frozen_string_literal: true

require 'lib/gemcache/ruby-nessus/ruby-nessus/log'
require 'lib/gemcache/ruby-nessus/ruby-nessus/Version1/version1'
require 'lib/gemcache/ruby-nessus/ruby-nessus/Version2/version2'

require 'nokogiri'
require 'date'
require 'time'

module Nessus
  class Parse
    def initialize(file, options = {}, &block)
      @file = File.open(file)
      @version = options[:version]
      @xml = Nokogiri::XML.parse(@file.read)

      if @version
        case @version
        when 1
          block&.call(Version1::XML.new(@xml))
        when 2
          block&.call(Version2::XML.new(@xml))
        else
          raise 'Error: Supported .Nessus Version are 1 and 2.'
        end
      elsif @xml.at('NessusClientData')
        block&.call(Version1::XML.new(@xml))
      elsif @xml.at('NessusClientData_v2')
        block&.call(Version2::XML.new(@xml))
      else
        raise 'Error: Supported .Nessus Version are 1 and 2.'
      end
    end
  end
end
