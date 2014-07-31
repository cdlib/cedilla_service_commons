require_relative '../test_helper'

require 'cedilla/error'

class TestError < Minitest::Test

  def setup
    @error = Cedilla::Error.new(Cedilla::Error::LEVELS[:error], "Test error message!")
  end

  # --------------------------------------------------------------------------------------------------------  
  def test_initialize
    # Not enough params (should toss an error)
    assert_raises(ArgumentError){ Cedilla::Error.new() }
    assert_raises(ArgumentError){ Cedilla::Error.new(1) }
    assert_raises(ArgumentError){ Cedilla::Error.new("fail") }
    
    # Too many arguments
    assert_raises(ArgumentError){ Cedilla::Error.new(1, "fail", {"foo" => "bar"}) }
    
    # Invalid level (should just default to error)
    assert_equal 'error', Cedilla::Error.new(-3, '').level, 'Was expecting negative level to default to :error'
    assert_equal 'error', Cedilla::Error.new(34, '').level, 'Was expecting invalid level to default to :error'
    assert_equal 'error', Cedilla::Error.new('abc', '').level, 'Was expecting invalid string level to default to :error'
    assert_equal 'error', Cedilla::Error.new(nil, '').level, 'Was expecting Nil level to default to :error'
    
    # Message not a string (should convert to a String)
    assert_equal '12345', Cedilla::Error.new(2, 12345).message, 'Was expecting Integer to convert to String!'
    assert_equal '', Cedilla::Error.new(2, nil).message, 'Was expecting Nil to convert to empty String!'
    assert_equal 'error', Cedilla::Error.new(2, :error).message, 'Was expecting Symbol to convert to String!'
    
    # Valid initialization
    assert_equal 'error', @error.level
    assert_equal 'Test error message!', @error.message
    
  end
  
  # --------------------------------------------------------------------------------------------------------  
  def test_to_hash
    hash = {"level" => 'error', "message" => "Test error message!"}
    
    assert_equal hash, @error.to_hash
  end

  # --------------------------------------------------------------------------------------------------------  
  def test_to_s
    assert_equal "error: Test error message!", @error.to_s, "Was expecting the to_s method to return 'level: message'!"
  end

  # --------------------------------------------------------------------------------------------------------  
  def test_set_level
    # default
    # -----------------------------------------------
    @error.level = nil
    assert_equal 'error', @error.level, "Was expecting a nil to default to 1 (error)!"
    
    # by number
    # -----------------------------------------------
    @error.level = 0
    assert_equal 'fatal', @error.level, "Was expecting a 0 to be set to 0 (fatal)!"
    
    @error.level = 1
    assert_equal 'error', @error.level, "Was expecting a 1 to be set to 1 (error)!"
    
    @error.level = 2
    assert_equal 'warning', @error.level, "Was expecting a 2 to be set to 2 (warning)!"
    
    @error.level = 3
    assert_equal 'error', @error.level, "Was expecting a 3 to default to 1 (error)!"
    
    @error.level = 999999
    assert_equal 'error', @error.level, "Was expecting a 99999 to default to 1 (error)!"
    
    @error.level = -45
    assert_equal 'error', @error.level, "Was expecting a -45 to default to 1 (error)!"
    
    @error.level = 9.8745
    assert_equal 'error', @error.level, "Was expecting a 9.8745 to default to 1 (error)!"
    
    # by string
    # -----------------------------------------------
    @error.level = 'debug'
    assert_equal 'warning', @error.level, "Was expecting 'debug' to be set to 2 (warning)!"
    
    @error.level = 'info'
    assert_equal 'warning', @error.level, "Was expecting 'info' to be set to 2 (warning)!"
    
    @error.level = 'warning'
    assert_equal 'warning', @error.level, "Was expecting 'warning' to be set to 2 (warning)!"
    
    @error.level = 'warn'
    assert_equal 'warning', @error.level, "Was expecting 'warn' to be set to 2 (warning)!"
    
    @error.level = 'error'
    assert_equal 'error', @error.level, "Was expecting 'error' to be set to 1 (error)!"
    
    @error.level = 'fatal'
    assert_equal 'fatal', @error.level, "Was expecting 'fatal' to be set to 0 (fatal)!"
    
    @error.level = 'foo'
    assert_equal 'error', @error.level, "Was expecting 'foo' to default to 1 (error)!"
    
    @error.level = 'abcdefghijklmnop'
    assert_equal 'error', @error.level, "Was expecting 'abcdefghijklmnop' to default to 1 (error)!"
    
    @error.level = ''
    assert_equal 'error', @error.level, "Was expecting '' to default to 1 (error)!"
    
    # by symbol
    # -----------------------------------------------
    @error.level = :warning
    assert_equal 'warning', @error.level, "Was expecting :warning to be set to 2 (warning)!"
    
    @error.level = :error
    assert_equal 'error', @error.level, "Was expecting :error to be set to 1 (error)!"
    
    @error.level = :fatal
    assert_equal 'fatal', @error.level, "Was expecting :fatal to be set to 0 (fatal)!"
    
    @error.level = :warn
    assert_equal 'error', @error.level, "Was expecting :warn to default to 1 (error)!"
    
    @error.level = :foo
    assert_equal 'error', @error.level, "Was expecting :foo to default to 1 (error)!"
  end
  
end