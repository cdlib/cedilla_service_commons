ENV['RACK_ENV'] = 'test'
$LOAD_PATH.unshift(File.absolute_path(File.join(File.dirname(__FILE__), '../')))
require 'rubygems'
require 'test/unit'
require 'cedilla'
