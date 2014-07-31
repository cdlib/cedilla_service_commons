require_relative './test_helper'

WebMock.disable_net_connect!(:allow_localhost => true)

require 'cedilla/service'

class CedillaTest < Minitest::Test

  def setup
    filepath = File.dirname(File.expand_path(__FILE__)) + '/config/'
    
    config_get = YAML::load(File.open(filepath + 'config_get.yaml'))
    
    @citation = Cedilla::Citation.new({:genre => 'book', 
                                      :title => 'The Metamorphosis', 
                                      :extras => {'foo' => ['bar']},
                                      :authors => [Cedilla::Author.from_abritrary_string('Kafka, Franz')]})
    
    @request = Cedilla::Request.new({:requestor_ip => '127.0.0.1',
                                      :unmapped => 'foo=bar',
                                      :api_ver => '1.0',
                                      :original_request => 'rft.genre=book&foo=bar&rft.title=The%20Metamorphosis&rft.aulast=Kafka&rft.aufirst=F',
                                      :citation => @citation})
  end
  
# ------------------------------------------------------------------------------------------------------------
  def test_initialization
    # Wrong number of arguments
    assert_raises(ArgumentError){ CedillaController.new("fail") }
    
    assert CedillaController.new.is_a?(CedillaController)
  end
  
# ------------------------------------------------------------------------------------------------------------  
  def test_handle_request
    cedilla = CedillaController.new
    
    # Check for bad JSON
    response = MockHttpResponse.new
    cedilla.handle_request(MockHttpRequest.new(MockHttpBody.new('{"test":"bad_json","data"')), response, @cedilla_get)
    assert_equal 400, response.status, "Was expecting an HTTP 400 response!"
    assert response.body.include?('unexpected token'), "Was expecting an 'unexpected token' message for an HTTP 400 response but got: #{response.body}"
    
    # Check for 404 handling
    response = MockHttpResponse.new
    cedilla.handle_request(MockHttpRequest.new(MockHttpBody.new(ARTICLE_JSON)), response, Mock404Service.new({}))
    assert_equal 404, response.status, "Was expecting an HTTP 404 response!"
    assert response.body.include?('"citations":[{}]'), "Was expecting a normal response with an empty citations element but got #{response.body}"
    
    response = MockHttpResponse.new
    cedilla.handle_request(MockHttpRequest.new(MockHttpBody.new(ARTICLE_JSON)), response, Mock404_2Service.new({}))
    assert_equal 404, response.status, "Was expecting an HTTP 404 response!"
    assert response.body.include?('"citations":[{}]'), "Was expecting a normal response with an empty citations element but got #{response.body}"
    
    # Check for 500 handling
    response = MockHttpResponse.new
    cedilla.handle_request(MockHttpRequest.new(MockHttpBody.new(ARTICLE_JSON)), response, Mock500Service.new({}))
    assert_equal 500, response.status, "Was expecting an HTTP 500 response!"
    assert response.body.include?('error occurred while processing '), "Was expecting an error message when receiving an HTTP 500 but got #{response.body}"
    
    # Successful call
    response = MockHttpResponse.new
    cedilla.handle_request(MockHttpRequest.new(MockHttpBody.new(ARTICLE_JSON)), response, MockService200Service.new({}))
    assert_equal 200, response.status, "Was expecting an HTTP 200 response!"
    assert response.body.include?('"citations":[{"document_id":"TESTING"}]'), "Was expecting a normal response with a citations element but got #{response.body}"
  end  

end

# ------------------------------------
class MockHttpResponse
  attr_accessor :status, :headers, :body
  
  def initialize
    @status = 500
    @headers = {}
    @body = ""
  end
end

# ------------------------------------
class MockHttpRequest
  attr_accessor :body, :ip, :referrer
  
  def initialize(body)
    @referrer = 'web.site.org'
    @body = body
    @ip = '127.0.0.1'
  end
end

# ------------------------------------
class MockHttpBody
  def initialize(json)
    @body = json
  end
  
  def rewind
    true
  end
  
  def read
    @body
  end
end

# ------------------------------------
class MockService200Service < Cedilla::Service
  def process_request(req, headers)
    return Cedilla::Citation.new({:document_id => 'TESTING'})
  end
end

# ------------------------------------
class Mock404Service < Cedilla::Service
  def validate_citation(citation)
    false
  end
end

# ------------------------------------
class Mock404_2Service < Cedilla::Service
  def process_request(req, headers)
    Cedilla::Citation.new({})
  end
end

# ------------------------------------
class Mock500Service < Cedilla::Service
  def process_request(req, headers)
    raise 'Testing 500 errors from service!'
  end
end