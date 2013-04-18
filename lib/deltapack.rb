require 'rubygems'
begin
  require 'bundler/setup'
  Bundler.setup
rescue
  puts "Couldn't load Bundler...  D'oh."
  exit 1
end

require 'rubygems/version'

$:.unshift(File.dirname(__FILE__))

module DeltaPack
  def self.version; @version ||= Gem::Version.new('0.0.1'); end
  def self.copyright; @copyright ||= "Copyright (C) 2013 Jonathon Frisby"; end
end

require 'deltapack/encoder'
require 'deltapack/packfileentry'
require 'deltapack/packfile'
