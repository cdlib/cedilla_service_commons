require_relative '../test_helper'

class TestResource < Minitest::Test

  def setup
    @print = Cedilla::Resource.new({:source => 'Campus', 
                                   :location => 'Main Stacks', 
                                   :local_title => 'Textbook for Class',
                                   :local_id => 'Z987 .Y987',
                                   :availability => false,
                                   :status => 'reserved',
                                   :description => 'the spine is not in great shape',
                                   :type => 'third edition, signed by author',
                                   :format => Cedilla::Resource::FORMATS[:print],
                                   :catalog_target => 'http://library.campus.edu/link/to/item',
                                   :language => 'English',
                                   :foo => 'bar'})
        
    @electronic = Cedilla::Resource.new({:source => 'Website', 
                                       :target => 'https://web.site.org/link/to/item/12345', 
                                       :local_title => 'Textbook for Class',
                                       :local_id => 'website:12345',
                                       :availability => true,
                                       :description => 'The definitive guide to class.',
                                       :format => Cedilla::Resource::FORMATS[:electronic],
                                       :license => 'open access',
                                       :language => 'English',
                                       :rating => '3.5',
                                       :foo => 'bar'})
  end

# --------------------------------------------------------------------------------------------------------  
  def test_initialization
    # Test worng number of parameters
    assert_raises(ArgumentError){ Cedilla::Resource.new() }
    assert_raises(ArgumentError){ Cedilla::Resource.new(1, 2) }
    
    # Test not a hash
    assert_raises(ArgumentError){ Cedilla::Resource.new(nil) }
    assert_raises(ArgumentError){ Cedilla::Resource.new('123') }
    assert_raises(ArgumentError){ Cedilla::Resource.new(123) }
    assert_raises(ArgumentError){ Cedilla::Resource.new(['bar','123']) }
    
    # Test valid resource
    resource = Cedilla::Resource.new({:source => 'Main Library', 
                                      :location => 'First floor', 
                                      :target => 'http://web.site.org/link/to/item', 
                                      :local_id => 'Z987 .Y987',
                                      :availability => false,
                                      :status => 'reserved',
                                      :description => 'the spine is not in great shape',
                                      :type => 'third edition, signed by author',
                                      :format => Cedilla::Resource::FORMATS[:print],
                                      :catalog_target => 'http://web.site.org/new/page',
                                      :foo => 'bar',
                                      :bogus_value1 => 'blah blah',
                                      :bogus_value2 => 15,
                                      :bogus_value3 => false})
                                      
    assert resource.valid?, "Was expecting the resource to be valid!"
    
    assert_equal 'Main Library', resource.source, "Was expecting the source to have been set properly!"
    assert_equal 'First floor', resource.location, "Was expecting the location to have been set properly!"
    assert_equal 'http://web.site.org/link/to/item', resource.target, "Was expecting the target to have been set properly!"
    assert_equal 'Z987 .Y987', resource.local_id, "Was expecting the local id to have been set properly!"
    assert_equal false, resource.availability, "Was expecting the availability to have been set properly!"
    assert_equal 'reserved', resource.status, "Was expecting the status to have been set properly!"
    assert_equal 'the spine is not in great shape', resource.description, "Was expecting the description to have been set properly!"
    assert_equal 'third edition, signed by author', resource.type, "Was expecting the type to have been set properly!"
    assert_equal 'print', resource.format, "Was expecting the format to have been set properly!"
    assert_equal 'http://web.site.org/new/page', resource.catalog_target, "Was expecting the catalog target to have been set properly!"
    assert_equal 'bar', resource.extras['foo'][0], "Was expecting there to be an extra called foo!"
    
  end

# --------------------------------------------------------------------------------------------------------  
  def test_validity
    # Valid because of target
    resource = Cedilla::Resource.new({:source => 'Website', 
                                      :target => 'http://web.site.org/link/to/item'})
    assert resource.valid?, "Was expecting a resource with a target to pass the validation check!"
                             
    # Valid because of catalog_target
    resource = Cedilla::Resource.new({:source => 'Library', 
                                      :catalog_target => 'http://my.campus.edu/link/to/item'})
    assert resource.valid?, "Was expecting a resource with a catalog target to pass the validation check!"
                                      
    # Valid because of local id
    resource = Cedilla::Resource.new({:source => 'Library', 
                                      :local_id => 'A123 .B1234'})                               
    assert resource.valid?, "Was expecting a resource with a local id to pass the validation check!"
    
    # Invalid because NO target or catalog_target or local_id
    resource = Cedilla::Resource.new({:source => 'Campus', 
                                      :location => 'Main Library'})
    assert !resource.valid?, "Was expecting a resource with no local id, target, or catalog target to fail the validation check!"
  end

# --------------------------------------------------------------------------------------------------------  
  def test_equality
    # Primary Key is: target or catalog_target or source + location + local_id
    a = Cedilla::Resource.new({:source => 'source 1', :location => 'location 1', :target => 'http://web.site.org/link/to/item', :local_id => 'Z987 .Y987'})
    b = Cedilla::Resource.new({:source => 'source 1', :location => 'location 1', :target => 'http://web.site.org/link/to/item', :local_id => 'A123 .B123', :catalog_target => 'http://my.campus.edu/link/to/item'})
    c = Cedilla::Resource.new({:source => 'source 1', :location => 'location 1', :local_id => 'Z987 .Y987', :catalog_target => 'http://my.campus.edu/link/to/item'})
    
    d = Cedilla::Resource.new({:source => 'source 1', :location => 'location 1'})
    e = Cedilla::Resource.new({:source => 'source 1', :target => 'http://web.site.org/link/to/item/abc'})
    f = Cedilla::Resource.new({:location => 'location 1', :catalog_target => 'http://web.site.org/link/to/item/123'})
    g = Cedilla::Resource.new({:source => 'source 1', :location => 'location 1', :target => 'http://web.site.org/link/to/item/2'})
    h = Cedilla::Resource.new({:source => 'source 1', :location => 'location 2', :local_id => 'Z987 .Y987'})
    i = Cedilla::Resource.new({:source => 'source 2', :location => 'location 1', :local_id => 'Z987 .Y987'})
    j = Cedilla::Resource.new({:source => 'source 1', :location => 'location 1', :local_id => 'Z987 .Y999'})
    
    assert a == b, "Resource A should have matched resource B because they have the same target!"
    assert a == c, "Resource A should have matched resource C because they have the same source + location + local_id"
    assert b == c, "Resource B should have matched resource C because they have the same catalog_target"
    
    assert a != d, "Resource A should NOT have matched resource D because D has no target, catalog_target, or local_id defined"
    assert a != e, "Resource A should NOT have matched resource E because the targets are different"
    assert a != f, "Resource A should NOT have matched resource F because the catalog_targets are different"
    assert a != g, "Resource A should NOT have matched resource G because the targets are different"
    assert a != h, "Resource A should NOT have matched resource H because the locations are different"
    assert a != i, "Resource A should NOT have matched resource I because the sources are different"
    assert a != j, "Resource A should NOT have matched resource J because the local_ids are different"
  end

# --------------------------------------------------------------------------------------------------------  
  def test_set_target
    resource = Cedilla::Resource.new({:source => 'Campus A', 
                                      :target => 'blah blah'})
    resource.target = 'http://web.site.org/link/to/item'
    assert resource.valid?, "Was expecting the resource to be valid"
    assert_equal 'http://web.site.org/link/to/item', resource.target, "Was expecting the target for resource to be valid after fixing the target"
  end
  
# --------------------------------------------------------------------------------------------------------    
  def test_set_catalog_target
    resource = Cedilla::Resource.new({:source => 'Campus A', 
                                      :target => 'http://web.site.org/link/to/item',
                                      :catalog_target => 'blah blah'})
    resource.catalog_target = 'http://web.site.org/link/to/item'
    assert resource.valid?, "Was expecting the resource to be valid"
    assert_equal 'http://web.site.org/link/to/item', resource.catalog_target, "Was expecting the catalog_target for resource to be valid after fixing the target"
  end
  
# --------------------------------------------------------------------------------------------------------    
  def test_set_availability
    a = Cedilla::Resource.new({:source => 'source 1', :location => 'location 1', :target => 'http://web.site.org/link/to/item1', :local_id => 'Z987 .Y987', :availability => false})
    b = Cedilla::Resource.new({:source => 'source 2', :location => 'location 2', :target => 'http://web.site.org/link/to/item2', :local_id => 'A123 .B123', :availability => true})
    c = Cedilla::Resource.new({:source => 'source 3', :location => 'location 3', :target => 'http://web.site.org/link/to/item3', :local_id => 'A123 .B123', :availability => 'blah'})

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
    resource = Cedilla::Resource.new({:source => 'Campus A', 
                                      :target => 'http://web.site.org/link/to/item', 
                                      :format => 'blah'})
    resource.format = Cedilla::Resource::FORMATS[:audio]
    #assert resource.errors.include?(:format), "Was expecting an invalid format exception!"
  end
  
# --------------------------------------------------------------------------------------------------------  
  def test_to_hash    
    resource = Cedilla::Resource.new({:source => 'test 1', 
                                      :location => 'here', 
                                      :target => 'http://web.site.org/link/to/item', 
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
    assert_equal 'http://web.site.org/link/to/item', hash['target'], "Was expecting the target to be 'blah blah'!"
    assert_equal 'This is my local title.', hash['local_title'], "Was expecting the local title to be 'This is my local title.'"
    assert_equal 'A123 .B1234', hash['local_id'], "Was expecting the local_id to be 'A123 .B1234'!"
    assert !hash['availability'], "Was expecting the availability to be 'false'!"
    assert_equal 'reserved', hash['status'], "Was expecting the status to be 'reserved'!"
    assert_equal 'blah blah', hash['description'], "Was expecting the description to be 'blah blah'!"
    assert_equal 'fun stuff', hash['type'], "Was expecting the type to be 'fun stuff'!"
    assert_equal 'electronic', hash['format'], "Was expecting the format to be electronic!"
    assert_equal 'http://ucop.edu', hash['catalog_target'], "Was expecting the catalog target to be 'http://ucop.edu'!"
    assert_equal 'French', hash['language'], "Was expecting the language to be 'French'"
    assert_equal 'public domain', hash['license'], "Was expecting the license to be 'public domain'"
    
    assert_equal ['blah'], hash['bogus_value1'], "Was expecting the bogus value to have been retained!"
  end

# --------------------------------------------------------------------------------------------------------  
  def test_to_s
    assert_equal "#{@electronic.target}", @electronic.to_s, "Was expecting the to_s method to return the target!"
    assert_equal "#{@print.catalog_target}", @print.to_s, "Was expecting the to_s method to return the catalog_target!"
    
    resource = Cedilla::Resource.new({:source => 'abc'})
    assert_equal "#{resource.source}", resource.to_s, "Was expecting the to_s method to return the source!"
    resource = Cedilla::Resource.new({:location => '123'})
    assert_equal "#{resource.location}", resource.to_s, "Was expecting the to_s method to return the location!"
    resource = Cedilla::Resource.new({:local_id => 'XYZ'})
    assert_equal "#{resource.local_id}", resource.to_s, "Was expecting the to_s method to return the local_id!"
    resource = Cedilla::Resource.new({:source => 'abc', :location => '123'})
    assert_equal "#{resource.source} - #{resource.location}", resource.to_s, "Was expecting the to_s method to return the source - location!"
    resource = Cedilla::Resource.new({:source => 'abc', :local_id => 'XYZ'})
    assert_equal "#{resource.source} - #{resource.local_id}", resource.to_s, "Was expecting the to_s method to return the source - local_id!"
    resource = Cedilla::Resource.new({:location => '123', :local_id => 'XYZ'})
    assert_equal "#{resource.location} - #{resource.local_id}", resource.to_s, "Was expecting the to_s method to return the location - local_id!"
    resource = Cedilla::Resource.new({:source => 'abc', :location => '123', :local_id => 'XYZ'})
    assert_equal "#{resource.source} - #{resource.location} - #{resource.local_id}", resource.to_s, "Was expecting the to_s method to return the source - location - local_id!"
  end
  
# --------------------------------------------------------------------------------------------------------  
  def test_allocation_of_extras
    assert_equal 1, @electronic.extras.count, "Was expecting to find one extra!"
    assert_equal 'bar', @electronic.extras['foo'][0], "Was expecting extras to contain 'foo' => ['bar']!"
    
    @electronic.extras['foo'] << 'bar2'
    @electronic.extras['blah'] = ['blah']
    
    assert_equal 2, @electronic.extras.count, "Was expecting to find two extras!"
    assert_equal 2, @electronic.extras['foo'].count, "Was expecting to find two values in foo!"
    assert_equal 'bar', @electronic.extras['foo'][0], "Was expecting extras to contain 'foo' => ['bar']!"
    assert_equal 'bar2', @electronic.extras['foo'][1], "Was expecting extras to contain 'foo' => ['bar2']!"
    assert_equal 'blah', @electronic.extras['blah'][0], "Was expecting extras to contain 'foo' => ['bar']!"
    
    assert_equal ['bar', 'bar2'], @electronic.extras['foo'], "Was expecting extras to contain 'foo' => ['bar', 'bar2']!"
    assert_equal ['blah'], @electronic.extras['blah'], "Was expecting extras to contain 'blah' => ['blah']!"
    
    @electronic.extras.delete('blah')
    assert_equal 1, @electronic.extras.count, "Was expecting to find one extra!"
    
    @electronic.extras.clear
    assert_equal 0, @electronic.extras.count, "Was expecting to find NO extras!"
  end
end