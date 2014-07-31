require_relative '../test_helper'

require 'cedilla/author'

class TestRequest < Minitest::Test

  def setup
    @request = Cedilla::Request.new({:requestor_ip => '127.0.0.1',
                                    :requestor_affiliation => 'CAMPUS-A',
                                    :requestor_language => 'en',
                                    :unmapped => 'foo=bar&ver=123.45',
                                    :original_request => 'foo=bar&rft.genre=article&doi=ABCD&ver=123.45',
                                    :referrers => ['site.org', 'other.edu'],
                                    :api_ver => '1.1',
                                    :id => 'ABCD1234EFGH6789',
                                    :time => Date.new,
                                    :citation => Cedilla::Citation.new({:genre => 'article', :doi => 'ABCD'})})
  end
      
# --------------------------------------------------------------------------------------------------
  def test_initialization
    # Wrong number of arguments
    assert_raises(ArgumentError){ Cedilla::Request.new() }
    assert_raises(ArgumentError){ Cedilla::Request.new("fail", {}) }
    
    # Argument not a Hash
    assert_raises(ArgumentError){ Cedilla::Request.new(nil) }
    assert_raises(ArgumentError){ Cedilla::Request.new('123') }
    assert_raises(ArgumentError){ Cedilla::Request.new(123) }
    assert_raises(ArgumentError){ Cedilla::Request.new(['bar','123']) }
    
    # Check values to make sure everything is set
    assert_equal '127.0.0.1', @request.requestor_ip, "Expected requestor_ip to be set on initialization!"
    assert_equal 'CAMPUS-A', @request.requestor_affiliation, "Expected requestor_affiliation to be set on initialization!"
    assert_equal 'en', @request.requestor_language, "Expected requestor_language to be set on initialization!"
    assert_equal 'foo=bar&ver=123.45', @request.unmapped, "Expected unmapped to be set on initialization!"
    assert_equal 'foo=bar&rft.genre=article&doi=ABCD&ver=123.45', @request.original_request, "Expected original_request to be set on initialization!"
    assert_equal ['site.org', 'other.edu'], @request.referrers, "Expected referrers to be set on initialization!"
    assert_equal '1.1', @request.api_ver, "Expected api_ver to be set on initialization!"
    assert_equal 'ABCD1234EFGH6789', @request.id, "Expected id to be set on initialization!"
    assert !@request.time.nil?, "Expected time to be set on initialization!"
    
    assert_equal Cedilla::Citation.new({:genre => 'article', :doi => 'ABCD'}), @request.citation, "Expected citation to be set on initialization!"
    
    req = Cedilla::Request.new({:citation => {:genre => 'book', :title => 'Test'}})
    assert_equal Cedilla::Citation.new({:genre => 'book', :title => 'Test'}), req.citation, "Expected to be able to set the citation if passed an attribute Hash"
  end

end
