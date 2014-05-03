require 'webmock/test_unit'
require_relative './test_helper'

WebMock.disable_net_connect!(:allow_localhost => true)

# This test object should only evaluate the generic functionality of the service object
# individual tests should be written for each implementation!!!
class CedillaTest < Test::Unit::TestCase

  def setup
    filepath = File.dirname(File.expand_path(__FILE__)) + '/config/'
    
    config_empty = YAML::load(File.open(filepath + 'config_empty.yaml'))
    config_get = YAML::load(File.open(filepath + 'config_get.yaml'))
    config_post = YAML::load(File.open(filepath + 'config_post.yaml'))
    
    @cedilla_empty = CedillaService.new(config_empty)
    @cedilla_get = CedillaService.new(config_get)
    @cedilla_post = CedillaService.new(config_post)
    
    @citation = Cedilla::Citation.new({:genre => 'book', :content_type => 'electronic', :title => 'The Metamorphosis', 
                                       :authors => [Cedilla::Author.new({:last_name => 'Kafka', :first_name => 'J'})],
                                       :resources => [{:source => 'source 1', :location => 'location 1'}, {:source => 'source 2', :target => 'http://www.ucop.edu/link/to/item', :availability => true}]})
  end
  
  def test_initialization
    # Test empty cedilla
    assert_equal "", @cedilla_empty.target, "Was expecting the target for cedilla_empty to be ''!"
    
    # Test both GET and POST services of cedilla
    svcs = {'get' => @cedilla_get, 'post' => @cedilla_post}
    
    svcs.each do |name, svc|
      assert_equal "http://my.service.org/#{name}", svc.target, "Was expecting the target for '#{name}' service to be 'http://my.service.org/#{name}'!"
      assert_equal "", svc.query_string, "Was expecting the query_string for '#{name}' service to be ''!"
      assert_equal (name == 'get' ? 2 : 3), svc.max_attempts, "Was expecting the '#{name}' service to have #{svc.max_attempts} max attempts!"
      assert_equal name, svc.http_method, "Was expecting the '#{name}' service to have an Http Method = '#{name}'!"
      assert_equal 5, svc.http_timeout, "Was expecting the '#{name}' service to have an Http timeout = 5!"
      assert_equal (name == 'get' ? true : false), svc.http_error_on_non_200, "Was expecting the '#{name}' service to #{name == 'get' ? '' : 'NOT' } auto-fail on non Http 2xx statuses!"
      assert_equal (name == 'get' ? 3 : 5), svc.http_max_redirects, "Was expecting the '#{name}' service to have #{svc.http_max_redirects} max redirects!"
      assert svc.http_cookies.nil?, "Was expecting the http_cookies for '#{name}' service to be nil!"
      assert !svc.translator.nil?, "Was expecting the translator for '#{name}' service to be nil!"
    end

  end
  
  # --------------------------------------------------------------------------------------------------------  
  def test_build_form_data
    data = @cedilla_post.build_form_data(@citation)
    #data: <input type='hidden' id='genre' name='genre' value='book' /><br />
    #      <input type='hidden' id='content_type' name='content_type' value='electronic' /><br />
    #      <input type='hidden' id='title' name='title' value='The Metamorphosis' /><br />
    #      <input type='hidden' id='full_name' name='full_name' value='J Kafka' /><br />
    #      <input type='hidden' id='last_name' name='last_name' value='Kafka' /><br />
    #      <input type='hidden' id='first_name' name='first_name' value='J' /><br />
    #      <input type='hidden' id='first_initial' name='first_initial' value='J.' /><br />
    #      <input type='hidden' id='initials' name='initials' value='J.' /><br />
    #      <input type='hidden' id='source' name='source' value='source 1' /><br />
    #      <input type='hidden' id='location' name='location' value='location 1' /><br />
    #      <input type='hidden' id='availability' name='availability' value='false' /><br />
    #      <input type='hidden' id='source' name='source' value='source 2' /><br />
    #      <input type='hidden' id='target' name='target' value='http://www.ucop.edu/link/to/item' /><br />
    #      <input type='hidden' id='availability' name='availability' value='true' />
    
    assert data.include?("<input type='hidden' id='title' name='title' value='The Metamorphosis' />"), "Was expecting the form data to contain the title!"
    assert data.include?("<input type='hidden' id='genre' name='genre' value='book' />"), "Was expecting the form data to contain the genre!"
    assert data.include?("<input type='hidden' id='content_type' name='content_type' value='electronic' />"), "Was expecting the form data to contain the content_type!"
    assert !data.include?("<input type='hidden' id='issn' name='issn' value='0123-4567' />"), "Was expecting the form data to NOT contain an ISSN!"
    assert data.include?("<input type='hidden' id='full_name' name='full_name' value='J Kafka' />"), "Was expecting the form data to contain the full_name!"
    assert data.include?("<input type='hidden' id='last_name' name='last_name' value='Kafka' />"), "Was expecting the form data to contain the last_name!"
    assert data.include?("<input type='hidden' id='first_name' name='first_name' value='J' />"), "Was expecting the form data to contain the last_name!"
    
  end
  
# --------------------------------------------------------------------------------------------------------  
  def test_add_citation_to_target
    out = @cedilla_get.add_citation_to_target(@citation)
    #out: http://my.service.org/get?genre=book&content_type=electronic&title=The%20Metamorphosis&full_name=J%20Kafka&last_name=Kafka&first_name=J&first_initial=J.&initials=J.
    
    assert out.include?("http://my.service.org/get"), "Was expecting the out to contain the url 'http://my.service.org/get'!"+out.to_s
    assert out.include?("last_name=Kafka"), "Was expecting the out to contain the query 'last_name=Kafka'!"
  end
  
# --------------------------------------------------------------------------------------------------------
  def test_process_response
    status = 200
    headers = {'content-length' => 10}
    body = '0123456789'
    
    result = @cedilla_get.process_response(status, headers, body)
    #response: HTTP Status: 200
    #          HTTP Headers: content-length => 10,
    #          HTTP Body: 0123456789.
    
    assert_equal "HTTP Status: 200\nHTTP Headers: content-length => 10, \nHTTP Body: 0123456789", result, "Was expecting response like 'HTTP Status: 200\nHTTP Headers: content-length => 10, \nHTTP Body: 0123456789'"+result.to_s
  end
  
# --------------------------------------------------------------------------------------------------------    
  def test_process_request
    puts "\n.... testing cedilla.process_request"
    
    # Run through all of the possible status codes
    # Informational Codes
    [100, 101].each{ |code| do_error_tests(code) }
    
    # Success Codes
    [200, 201, 202, 203, 204, 205, 206].each{ |code| do_success_tests(code) }
    
    # Moves/Redirects - commented out because the stub_request with redirect is not reliable for now 
    #[300, 301, 302, 303, 304, 305, 306, 307].each{ |code| do_redirect_tests(code) }
    
    # Bad Requests
    [400, 401, 402, 403, 404, 405, 406, 407, 408, 409, 
              410, 411, 412, 413, 414, 415, 416, 417].each{ |code| do_error_tests(code) }
    
    # Server Errors
    [500, 501, 502, 503, 504, 505].each{ |code| do_error_tests(code) }

  end
  
# --------------------------------------------------------------------------------------------------------    
  def do_success_tests(http_status)
    puts "...... testing HTTP #{http_status} codes from service endpoint"
    
    # Test both cedilla_get and cedilla_post services with success code: 200, 201, 202, 203, 204, 205, 206
    svcs = {'get' => @cedilla_get, 'post' => @cedilla_post}
    
    svcs.each do |name, svc|
      svc.attempts = 0
      target = (name == 'get') ? svc.add_citation_to_target(@citation) : svc.target
      stub_request(:"#{name}", target)
                   .to_return(:status => http_status, :headers => {'Content-Length' => 10}, :body => '1234567890')
      
      result = svc.process_request(@citation, {})
      
      # Make sure the status, headers, and body are stored
      assert_equal http_status, svc.response_status, "Was expecting the response code of 'cedilla_#{name}' service to be #{http_status} on success!"
      assert_equal '10', svc.response_headers['content-length'], "Was expecting the response header, 'content-length' of 'cedilla_#{name}' service to be 10 on success!"
      assert_equal '1234567890', svc.response_body, "Was expecting the response body of 'cedilla_#{name}' service to be '1234567890' on success!"
      
      # Only one attempt for both get and post services on the success contact
      assert_equal 1, svc.attempts, "Was expecting the attempts of 'cedilla_#{name}' service to be 1 on success!"
    end
  end
  
# --------------------------------------------------------------------------------------------------------    
  def do_redirect_tests2(http_status)
    puts "...... testing HTTP #{http_status} codes from service endpoint"
    # Test both cedilla_get and cedilla_post services with success code: 300, 301, 302, 303, 304, 305, 306, 307
    puts "........ testing HTTP #{http_status} codes with 8 redirects"
    # Stub out the redirects for the default of 8 times
    svc =  @cedilla_get
    target = "http://my.service.org:80/"
    stub_request(:any, target).to_return({:status => http_status}).times(8).then.to_return({:status => 200, :headers => {'content-length' => 10}, :body => '1234567890'})
    result = svc.process_request(@citation, {})
    #assert_equal 1, svc.redirects, "Was expecting the 'cedilla_get' service to redirect #{svc.http_max_redirects} times for code '#{http_status}'!"+svc.aa1+svc.aa2+svc.aa3+svc.aa4+svc.aa5+svc.aa6
    
    puts "...... testing HTTP #{http_status} codes from service endpoint"
    # Test both cedilla_get and cedilla_post services with success code: 300, 301, 302, 303, 304, 305, 306, 307
    puts "........ testing HTTP #{http_status} codes with 8 redirects"
    # Stub out the redirects for the default of 8 times
    svc =  @cedilla_get
    target = "http://my.service.org:80/"
    stub_request(:any, target).to_return({:status => http_status}).times(3).then.to_return({:status => 200, :headers => {'content-length' => 10}, :body => '1234567890'})
    result = svc.process_request(@citation, {})
    assert_equal 1, svc.redirects, "Was expecting the 'cedilla_get' service to redirect #{svc.http_max_redirects} times for code '#{http_status}'!"+svc.aa1+svc.aa2+svc.aa3+svc.aa4+svc.aa5+svc.aa6
    
  end
  
# --------------------------------------------------------------------------------------------------------    
  def do_redirect_tests(http_status)
    puts "...... testing HTTP #{http_status} codes from service endpoint"
    
    # Test both cedilla_get and cedilla_post services with success code: 300, 301, 302, 303, 304, 305, 306, 307
    svcs = {'get' => @cedilla_get, 'post' => @cedilla_post}
    
    # Stub out the redirects for the default of 8 times
    svcs.each do |name, svc|
      svc.redirects = 0
      #target = (name == 'get') ? svc.add_citation_to_target(@citation) : svc.target
      target = "http://my.service.org:80/"
      stub_request(:any, target).to_return({:status => http_status, :headers => {'Content-Length' => 10}, :body => '1234567890'}).times(8).then.
                                       to_return({:status => 200, :headers => {'content-length' => 10}, :body => '1234567890'})
      
      result = svc.process_request(@citation, {})
      
      # Make sure the services will only redirect for the max number of times, cedilla_get: 3 and cedilla_post: 5
      assert_equal (name == 'get' ? 3 : 5), svc.redirects, "Was expecting the 'cedilla_#{name}' service to redirect #{svc.http_max_redirects} times for code '#{http_status}'!"
      assert_equal 200, svc.response_status, "Was expecting the response code to be 200 at the end of the redirect chain!"
      assert_equal '10', svc.response_headers['content-length'], "Was expecting the response header, 'content-length' to be 10 at the end of the redirect chain!"
      assert_equal '1234567890', svc.response_body, "Was expecting the response body to be '1234567890' at the end of the redirect chain!"
    end
    
    # Stub out the redirects for the default of 5 times
    svcs.each do |name, svc|
      svc.redirects = 0
      target = (name == 'get') ? svc.add_citation_to_target(@citation) : svc.target
      stub_request(:"#{name}", target).to_return({:status => http_status, :headers => {'Content-Length' => 10}, :body => '1234567890'}).times(5).then
                   .to_return(:status => 200, :headers => {'Content-Length' => 10}, :body => '1234567890')
      
      result = svc.process_request(@citation, {})
      
      # Make sure the services will only redirect for the max number of times, cedilla_get: 3 and cedilla_post: 5
      assert_equal (name == 'get' ? 3 : 5), svc.redirects, "Was expecting the service to redirect #{svc.http_max_redirects} times, the default."
      assert_equal 200, svc.response_status, "Was expecting the response code to be 200 at the end of the redirect chain!"
      assert_equal '10', svc.response_headers['content-length'], "Was expecting the response header, 'content-length' to be 10 at the end of the redirect chain!"
      assert_equal '1234567890', svc.response_body, "Was expecting the response body to be '1234567890' at the end of the redirect chain!"
    end
    
    # Stub out the redirects for the default of 4 times
    svcs.each do |name, svc|
      svc.redirects = 0
      target = (name == 'get') ? svc.add_citation_to_target(@citation) : svc.target
      stub_request(:"#{name}", target).to_return({:status => http_status, :headers => {'Content-Length' => 10}, :body => '1234567890'}).times(4).then
                   .to_return(:status => 200, :headers => {'Content-Length' => 10}, :body => '1234567890')
      
      result = svc.process_request(@citation, {})
      
      # Make sure the services will only redirect for the specific number of times if it is less than the max number, cedilla_get: 3 and cedilla_post: 5
      assert_equal (name == 'get' ? 3 : 4), svc.redirects, "Was expecting the 'cedilla_#{name}' service to redirect #{svc.http_max_redirects} or less times."
      assert_equal 200, svc.response_status, "Was expecting the response code to be 200 at the end of the redirect chain!"
      assert_equal '10', svc.response_headers['content-length'], "Was expecting the response header, 'content-length' to be 10 at the end of the redirect chain!"
      assert_equal '1234567890', svc.response_body, "Was expecting the response body to be '1234567890' at the end of the redirect chain!"
    end
    
    # Stub out the redirects for the default of 2 times
    svcs.each do |name, svc|
      svc.redirects = 0
      target = (name == 'get') ? svc.add_citation_to_target(@citation) : svc.target
      stub_request(:"#{name}", target).to_return({:status => http_status, :headers => {'Content-Length' => 10}, :body => '1234567890'}).times(2).then
                   .to_return(:status => 200, :headers => {'Content-Length' => 10}, :body => '1234567890')
      
      result = svc.process_request(@citation, {})
      
      # Make sure the services will only redirect 2 times
      assert_equal 2, svc.redirects, "Was expecting the service to redirect 2 times."
      assert_equal 200, svc.response_status, "Was expecting the response code to be 200 at the end of the redirect chain!"
      assert_equal '10', svc.response_headers['content-length'], "Was expecting the response header, 'content-length' to be 10 at the end of the redirect chain!"
      assert_equal '1234567890', svc.response_body, "Was expecting the response body to be '1234567890' at the end of the redirect chain!"
    end
  end
  
# --------------------------------------------------------------------------------------------------------    
  def do_error_tests(http_status)
    puts "...... testing HTTP #{http_status} codes from service endpoint"
    
    # Test both cedilla_get and cedilla_post services with error code: 100, 101, 400, 401, ...
    # 1. cedilla_get service: a non HTTP 2xx code raise an exception as its supposed to
    svc = @cedilla_get
    svc.attempts = 0
    target = svc.add_citation_to_target(@citation)
    stub_request(:get, target).to_return(:status => http_status, :headers => {'Content-Length' => 10}, :body => '1234567890')
    
    assert_raise(Exception){ svc.process_request(@citation, {}) }
    
    # Make sure the request process tries the call for the specified number of times
    assert_equal 2, svc.attempts, "Was expecting the attempts of 'cedilla_get' service to be '#{svc.max_attempts}' on error!"
    
    # Make sure the status, headers, and body are stored
    assert_equal http_status, svc.response_status, "Was expecting the response code to be #{http_status} when raising an error!"
    assert_equal '10', svc.response_headers['content-length'], "Was expecting the response header, 'content-length' to be 10 when raising an error!"
    assert_equal '1234567890', svc.response_body, "Was expecting the response body to be '1234567890' when raising an error!"
      
    # 2. cedilla_post service: a non HTTP 2xx code does NOT raise an exception as its NOT supposed to
    svc = @cedilla_post
    svc.attempts = 0
    target = svc.target
    stub_request(:post, target).to_return(:status => http_status, :headers => {'Content-Length' => 10}, :body => '1234567890')
    
    result = svc.process_request(@citation, {})
    
    # Make sure the request process tries the call for the specified number of times
    assert_equal 1, svc.attempts, "Was expecting the 'cedilla_post' service to contact #{target} once when we're allowing non-2xx codes!"
    
    # Make sure the status, headers, and body are stored
    assert_equal http_status, svc.response_status, "Was expecting the response code to be #{http_status} when raising an error!"
    assert_equal '10', svc.response_headers['content-length'], "Was expecting the response header, 'content-length' to be 10 when raising an error!"
    assert_equal '1234567890', svc.response_body, "Was expecting the response body to be '1234567890' when raising an error!"
  end
end