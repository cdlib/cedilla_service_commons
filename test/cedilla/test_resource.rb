require_relative '../test_helper'

class TestResource < Test::Unit::TestCase

  def setup
    
  end

# --------------------------------------------------------------------------------------------------------  
  def test_initialization

    # Test valid resource
    resource = Cedilla::Resource.new({:source => 'Berkeley', 
                                      :location => 'First floor', 
                                      :target => 'http://www.ucop.edu/link/to/item', 
                                      :local_id => 'Z987 .Y987',
                                      :availability => false,
                                      :status => 'reserved',
                                      :description => 'the spine is not in great shape',
                                      :type => 'third edition, signed by author',
                                      :format => Cedilla::Resource::FORMATS[:print],
                                      :catalog_target => 'http://www.ucop.edu/new/page',
                                      :bogus_value1 => 'blah blah',
                                      :bogus_value2 => 15,
                                      :bogus_value3 => false})
    assert resource.valid?, "Was expecting the resource to be valid!"
    
    assert_equal 'Berkeley', resource.source, "Was expecting the source to have been set properly!"
    assert_equal 'First floor', resource.location, "Was expecting the location to have been set properly!"
    assert_equal 'http://www.ucop.edu/link/to/item', resource.target, "Was expecting the target to have been set properly!"
    assert_equal 'Z987 .Y987', resource.local_id, "Was expecting the local id to have been set properly!"
    assert_equal false, resource.availability, "Was expecting the availability to have been set properly!"
    assert_equal 'reserved', resource.status, "Was expecting the status to have been set properly!"
    assert_equal 'the spine is not in great shape', resource.description, "Was expecting the description to have been set properly!"
    assert_equal 'third edition, signed by author', resource.type, "Was expecting the type to have been set properly!"
    assert_equal Cedilla::Resource::FORMATS[:print], resource.format, "Was expecting the format to have been set properly!"
    assert_equal 'http://www.ucop.edu/new/page', resource.catalog_target, "Was expecting the catalog target to have been set properly!"
    assert_equal 3, resource.others.count, "Was expecting 3 other properties in the array!"
    
  end

# --------------------------------------------------------------------------------------------------------  
  def test_validity
    # Valid because of target
    resource = Cedilla::Resource.new({:source => 'Berkeley', 
                                      :target => 'http://www.ucop.edu/link/to/item'})
    assert resource.valid?, "Was expecting a resource with a target to pass the validation check!"
                             
    # Valid because of catalog_target
    resource = Cedilla::Resource.new({:source => 'Berkeley', 
                                      :catalog_target => 'http://www.ucop.edu/link/to/item'})
    assert resource.valid?, "Was expecting a resource with a catalog target to pass the validation check!"
                                      
    # Valid because of local id
    resource = Cedilla::Resource.new({:source => 'Berkeley', 
                                      :local_id => 'A123 .B1234'})                               
    assert resource.valid?, "Was expecting a resource with a local id to pass the validation check!"
    
    # Invalid because NO target or catalog_target or local_id
    resource = Cedilla::Resource.new({:source => 'Berkeley', 
                                      :location => 'Main Library'})
    assert !resource.valid?, "Was expecting a resource with no local id, target, or catalog target to fail the validation check!"

  end

# --------------------------------------------------------------------------------------------------------  
  def test_equality
    # Primary Key is: source + location + target
    a = Cedilla::Resource.new({:source => 'source 1', :location => 'location 1', :target => 'http://www.ucop.edu/link/to/item', :local_id => 'Z987 .Y987'})
    b = Cedilla::Resource.new({:source => 'source 1', :location => 'location 1', :target => 'http://www.ucop.edu/link/to/item', :local_id => 'A123 .B123'})
    c = Cedilla::Resource.new({:source => 'source 1', :location => 'location 1', :target => 'http://www.ucop.edu/link/to/item'})
    
    d = Cedilla::Resource.new({:source => 'source 1', :location => 'location 1'})
    e = Cedilla::Resource.new({:source => 'source 1', :target => 'http://www.ucop.edu/link/to/item'})
    f = Cedilla::Resource.new({:location => 'location 1', :target => 'http://www.ucop.edu/link/to/item'})
    g = Cedilla::Resource.new({:source => 'source 1', :location => 'location 1', :target => 'http://www.ucop.edu/link/to/item/2'})
    h = Cedilla::Resource.new({:source => 'source 1', :location => 'location 2', :target => 'http://www.ucop.edu/link/to/item'})
    i = Cedilla::Resource.new({:source => 'source 2', :location => 'location 1', :target => 'http://www.ucop.edu/link/to/item'})
    
    assert a == b, "Resource A should have matched resource B!"
    assert a == c, "Resource A should have matched resource C!"
    assert b == c, "Resource B should have matched resource C!"
    
    assert a != d, "Resource A should NOT have matched resource D"
    assert a != e, "Resource A should NOT have matched resource E"
    assert a != f, "Resource A should NOT have matched resource F"
    assert a != g, "Resource A should NOT have matched resource G"
    assert a != h, "Resource A should NOT have matched resource H"
    assert a != i, "Resource A should NOT have matched resource I"
  end

# --------------------------------------------------------------------------------------------------------  
  def test_set_target
    resource = Cedilla::Resource.new({:source => 'Berkeley', 
                                      :target => 'blah blah'})
    resource.target = 'http://www.ucop.edu/link/to/item'
    assert resource.valid?, "Was expecting the resource to be valid"
    assert_equal 'http://www.ucop.edu/link/to/item', resource.target, "Was expecting the target for resource to be valid after fixing the target"
  end
  
# --------------------------------------------------------------------------------------------------------    
  def test_set_content_type
    resource = Cedilla::Resource.new({:source => 'Berkeley', 
                                      :target => 'http://www.ucop.edu/link/to/item',
                                      :catalog_target => 'blah blah'})
    resource.catalog_target = 'http://www.ucop.edu/link/to/item'
    assert resource.valid?, "Was expecting the resource to be valid"
    assert_equal 'http://www.ucop.edu/link/to/item', resource.catalog_target, "Was expecting the catalog_target for resource to be valid after fixing the target"
  end
  
# --------------------------------------------------------------------------------------------------------    
  def test_set_availability
    a = Cedilla::Resource.new({:source => 'source 1', :location => 'location 1', :target => 'http://www.ucop.edu/link/to/item1', :local_id => 'Z987 .Y987', :availability => false})
    b = Cedilla::Resource.new({:source => 'source 2', :location => 'location 2', :target => 'http://www.ucop.edu/link/to/item2', :local_id => 'A123 .B123', :availability => true})
    c = Cedilla::Resource.new({:source => 'source 3', :location => 'location 3', :target => 'http://www.ucop.edu/link/to/item3', :local_id => 'A123 .B123', :availability => 'blah'})

    assert !a.availability, "Was expecting the availability to be false!"
    a.availability = true
    assert a.availability, "Was expecting the availability to be true!"
    a.availability = false
    assert !a.availability, "Was expecting the availability to be false!"
    
    assert b.availability, "Resource b's availability should be true!"
    assert !c.availability, "Resource c's availability should be false!"
  end
  
# --------------------------------------------------------------------------------------------------------    
  def test_set_format
    # Test invalid format 
    resource = Cedilla::Resource.new({:source => 'Berkeley', 
                                      :target => 'http://www.ucop.edu/link/to/item', 
                                      :format => 'blah'})
    resource.format = Cedilla::Resource::FORMATS[:audio]
    #assert resource.errors.include?(:format), "Was expecting an invalid format exception!"
  end
  
# --------------------------------------------------------------------------------------------------------  
  def test_to_hash    
    resource = Cedilla::Resource.new({:source => 'test 1', 
                                      :location => 'here', 
                                      :target => 'http://www.ucop.edu/link/to/item', 
                                      :local_title => 'This is my local title.',
                                      :local_id => 'A123 .B1234', 
                                      :availability => false, 
                                      :status => 'reserved', 
                                      :description => 'blah blah', 
                                      :type => 'fun stuff', 
                                      :format => Cedilla::Resource::FORMATS[:electronic], 
                                      :catalog_target => 'http://ucop.edu', 
                                      :language => 'French',
                                      :license => 'public domain',
                                      :bogus_value1 => 'blah'})
    
    #assert_equal 0, resource.errors.count, "Was expecting no validation errors!"
    assert resource.valid?, "Was expecting the resource to be valid!"
    
    hash = resource.to_hash
    
    assert_equal 'test 1', hash['source'], "Was expecting the source to be 'test 1'!"
    assert_equal 'here', hash['location'], "Was expecting the location to be 'here'!"
    assert_equal 'http://www.ucop.edu/link/to/item', hash['target'], "Was expecting the target to be 'blah blah'!"
    assert_equal 'This is my local title.', hash['local_title'], "Was expecting the local title to be 'This is my local title.'"
    assert_equal 'A123 .B1234', hash['local_id'], "Was expecting the local_id to be 'A123 .B1234'!"
    assert !hash['availability'], "Was expecting the availability to be 'false'!"
    assert_equal 'reserved', hash['status'], "Was expecting the status to be 'reserved'!"
    assert_equal 'blah blah', hash['description'], "Was expecting the description to be 'blah blah'!"
    assert_equal 'fun stuff', hash['type'], "Was expecting the type to be 'fun stuff'!"
    assert_equal Cedilla::Resource::FORMATS[:electronic], hash['format'], "Was expecting the format to be electronic!"
    assert_equal 'http://ucop.edu', hash['catalog_target'], "Was expecting the catalog target to be 'http://ucop.edu'!"
    assert_equal 'French', hash['language'], "Was expecting the language to be 'French'"
    assert_equal 'public domain', hash['license'], "Was expecting the license to be 'public domain'"
    
    assert_equal 'blah', hash['bogus_value1'], "Was expecting the bogus value to have been retained!"
  end
    
end