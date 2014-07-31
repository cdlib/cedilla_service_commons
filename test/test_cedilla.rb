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
  

end