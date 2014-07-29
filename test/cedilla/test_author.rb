require_relative '../test_helper'

require 'cedilla/author'

class TestAuthor < Minitest::Test

  def setup
    @author = Cedilla::Author.new({:full_name => 'Doe Jr., John A.', 
                                   :last_name => 'Doe', 
                                   :first_name => 'John', 
                                   :suffix => 'Jr.',
                                   :middle_initial => 'A.', 
                                   :first_initial => 'J.', 
                                   :initials => 'J. A.', 
                                   :dates => '1900-1980',
                                   :authority => 'http://localhost:8080/author/doe/john',
                                   :foo => 'blah'})
                                   
    @corporate = Cedilla::Author.new({:corporate_author => 'Some organization', 
                                      :dates => '1993-'})
  end

# --------------------------------------------------------------------------------------------------
  def test_initialization
    # Wrong number of arguments
    assert_raises(ArgumentError){ Cedilla::Author.new() }
    assert_raises(ArgumentError){ Cedilla::Author.new("fail", {}) }
    
    # Argument not a Hash
    assert_raises(ArgumentError){ Cedilla::Author.new(nil) }
    assert_raises(ArgumentError){ Cedilla::Author.new('123') }
    assert_raises(ArgumentError){ Cedilla::Author.new(123) }
    assert_raises(ArgumentError){ Cedilla::Author.new(['bar','123']) }
    
    # Check values to make sure everything is set
    assert_equal 'John A. Doe', @author.full_name, "Expected full name to be set on initialization!"
    assert_equal 'Doe', @author.last_name, "Expected last name to be set on initialization!"
    assert_equal 'John', @author.first_name, "Expected first name to be set on initialization!"
    assert_equal 'Jr.', @author.suffix, "Expected suffix to be set on initialization!"
    assert_equal 'A.', @author.middle_initial, "Expected middle initial to be set on initialization!"
    assert_equal 'J.', @author.first_initial, "Expected first initial to be set on initialization!"
    assert_equal 'J. A.', @author.initials, "Expected initials to be set on initialization!"
    assert_equal '1900-1980', @author.dates, "Expected dates to be set on initialization!"
    assert_equal 'http://localhost:8080/author/doe/john', @author.authority, "Expected authority to be set on initialization!"
    assert_equal 'blah', @author.extras['foo'].first, "Expected extras to contain 'foo' to be set on initialization!"
    
    assert_equal 'Some organization', @corporate.corporate_author, "Expected corporate author to be set on initialization!"
    assert_equal '1993-', @corporate.dates, "Expected dates to be set on initialization!"
    
  end
  
# --------------------------------------------------------------------------------------------------
  def test_equality
    # Test invalid match
    auth = Cedilla::Author.new({:last_name => 'Doe', :first_name => 'Jane'})
    refute_match @author, auth, "Was expecting Jane and John Doe's to NOT be equal!"
    
    auth = Cedilla::Author.new({:last_name => 'Smith', :first_name => 'John'})
    refute_match @author, auth, "Was expecting John Smith and John Doe to NOT be equal!"
    
    # Test valid match
    auth = Cedilla::Author.new({:last_name => 'Doe', :first_name => 'John', :middle_initial => 'A.'})
    assert_equal @author, auth, "Was expecting the 2 John Doe's to be equal!"
    
    auth = Cedilla::Author.new({:last_name => 'Doe', :first_name => 'John'})
    assert_equal @author, auth, "Was expecting the 2 John Doe's to be equal!"
    
    auth = Cedilla::Author.new({:last_name => 'Doe', :first_initial => 'J.'})
    assert_equal @author, auth, "Was expecting the 2 John Doe's to be equal!"
    
    auth = Cedilla::Author.new({:last_name => 'Doe', :first_name => 'J'})
    assert_equal @author, auth, "Was expecting the 2 John Doe's to be equal!"
    
    auth = Cedilla::Author.new({:full_name => 'Doe, John'})
    assert_equal @author, auth, "Was expecting the 2 John Doe's to be equal!"
    
    auth = Cedilla::Author.new({:full_name => 'Doe, John A.'})
    assert_equal @author, auth, "Was expecting the 2 John Doe's to be equal!"
    
    auth = Cedilla::Author.new({:full_name => 'John Doe'})
    assert_equal @author, auth, "Was expecting the 2 John Doe's to be equal!"
    
    auth = Cedilla::Author.new({:full_name => 'John A. Doe'})
    assert_equal @author, auth, "Was expecting the 2 John Doe's to be equal!"
  end

# --------------------------------------------------------------------------------------------------
  def test_arbitrary_name_handling
    auth = Cedilla::Author.from_abritrary_string('Sam, Yosemite A.')
    assert_equal 'Yosemite A. Sam', auth.full_name, "Wrong full_name for 'Sam, Yosemite A.'"
    assert_equal 'Yosemite', auth.first_name, "Wrong first_name for 'Sam, Yosemite A.'"
    assert_equal 'Sam', auth.last_name, "Wrong last_name for 'Sam, Yosemite A.'"
    assert_equal 'A.', auth.middle_initial, "Wrong middle_initial for 'Sam, Yosemite A.'"
    assert_equal 'Y.', auth.first_initial, "Wrong first_initial for 'Sam, Yosemite A.'"
    assert_equal 'Y. A.', auth.initials, "Wrong initials for 'Sam, Yosemite A.'"
    
    auth = Cedilla::Author.from_abritrary_string('Sam, Y. A.')
    assert_equal 'Y. A. Sam', auth.full_name, "Wrong full_name for 'Sam, Y. A.'"
    assert_equal 'Y.', auth.first_name, "Wrong first_name for 'Sam, Y. A.'"
    assert_equal 'Sam', auth.last_name, "Wrong last_name for 'Sam, Y. A.'"
    assert_equal 'A.', auth.middle_initial, "Wrong middle_initial for 'Sam, Y. A.'"
    assert_equal 'Y.', auth.first_initial, "Wrong first_initial for 'Sam, Y. A.'"
    assert_equal 'Y. A.', auth.initials, "Wrong initials for 'Sam, Y. A.'"
    
    auth = Cedilla::Author.from_abritrary_string('Y. A. Sam')
    assert_equal 'Y. A. Sam', auth.full_name, "Wrong full_name for 'Y. A. Sam'"
    assert_equal 'Y.', auth.first_name, "Wrong first_name for 'Y. A. Sam'"
    assert_equal 'Sam', auth.last_name, "Wrong last_name for 'Y. A. Sam'"
    assert_equal 'A.', auth.middle_initial, "Wrong middle_initial for 'Y. A. Sam'"
    assert_equal 'Y.', auth.first_initial, "Wrong first_initial for 'Y. A. Sam'"
    assert_equal 'Y. A.', auth.initials, "Wrong initials for 'Y. A. Sam'"
    
    auth = Cedilla::Author.from_abritrary_string('Yosemite A. Sam')
    assert_equal 'Yosemite A. Sam', auth.full_name, "Wrong full_name for 'Yosemite A. Sam'"
    assert_equal 'Yosemite', auth.first_name, "Wrong first_name for 'Yosemite A. Sam'"
    assert_equal 'Sam', auth.last_name, "Wrong last_name for 'Yosemite A. Sam'"
    assert_equal 'A.', auth.middle_initial, "Wrong middle_intial for 'Yosemite A. Sam'"
    assert_equal 'Y.', auth.first_initial, "Wrong first_initial for 'Yosemite A. Sam'"
    assert_equal 'Y. A.', auth.initials, "Wrong intials for 'Yosemite A. Sam'"
    
    auth = Cedilla::Author.from_abritrary_string('Sam, Yosemite')
    assert_equal 'Yosemite Sam', auth.full_name, "Wrong full_name for 'Sam, Yosemite'"
    assert_equal 'Yosemite', auth.first_name, "Wrong first_name for 'Sam, Yosemite'"
    assert_equal 'Sam', auth.last_name, "Wrong last_name for 'Sam, Yosemite'"
    assert_equal nil, auth.middle_initial, "Wrong middle_initial for 'Sam, Yosemite'"
    assert_equal 'Y.', auth.first_initial, "Wrong first_initial for 'Sam, Yosemite'"
    assert_equal 'Y.', auth.initials, "Wrong initials for 'Sam, Yosemite'"
    
    auth = Cedilla::Author.from_abritrary_string('Yosemite Sam')
    assert_equal 'Yosemite Sam', auth.full_name, "Wrong full_name for 'Yosemite Sam'"
    assert_equal 'Yosemite', auth.first_name, "Wrong first_name for 'Yosemite Sam'"
    assert_equal 'Sam', auth.last_name, "Wrong last_name for 'Yosemite Sam'"
    assert_equal nil, auth.middle_initial, "Wrong middle_initial for 'Yosemite Sam'"
    assert_equal 'Y.', auth.first_initial, "Wrong first_initial for 'Yosemite Sam'"
    assert_equal 'Y.', auth.initials, "Wrong initials for 'Yosemite Sam'"
    
    auth = Cedilla::Author.from_abritrary_string('Yosemite')
    assert_equal 'Yosemite', auth.full_name, "Wrong full_name for 'Yosemite'"
    assert_equal nil, auth.first_name, "Wrong first_name for 'Yosemite'"
    assert_equal 'Yosemite', auth.last_name, "Wrong last_name for 'Yosemite'"
    assert_equal nil, auth.middle_initial, "Wrong middle_initial for 'Yosemite'"
    assert_equal nil, auth.first_initial, "Wrong first_initial for 'Yosemite'"
    assert_equal nil, auth.initials, "Wrong initials for 'Yosemite'"
  end

# --------------------------------------------------------------------------------------------------
  def test_set_first_name
    auth = Cedilla::Author.new({:last_name => 'Duck'})
    
    auth.first_name = 'Daffy'
    assert_equal 'Daffy', auth.first_name, "Was expecting the first name to be 'Daffy'!"
    assert_equal 'D.', auth.first_initial, "Was expecting the first initial to be 'D.'!"
    assert_equal 'Daffy Duck', auth.full_name, "Was expecting the full name to be 'Daffy Duck'!"
  end

  def test_set_first_initial
    auth = Cedilla::Author.new({:last_name => 'Duck'})
    
    auth.first_initial = 'D.'
    assert_equal 'D.', auth.first_initial, "Was expecting the first initial to be 'D. Duck'!"
    assert_equal 'D. Duck', auth.full_name, "Was expecting the full name to be 'D. Duck'!"
  end

  def test_set_middle_initial
    auth = Cedilla::Author.new({:last_name => 'Duck'})
    
    auth.middle_initial = 'X.'
    assert_equal 'X.', auth.middle_initial, "Was expecting the middle initial to be 'X.'!"
    assert_equal 'X. Duck', auth.full_name, "Was expecting the full name to be 'X. Duck'!"
  end

  def test_set_initials
    auth = Cedilla::Author.new({:last_name => 'Duck'})
    
    auth.initials = 'D. X.'
    assert_equal 'D. X.', auth.initials, "Was expecting the middle initial to be 'D. X.'!"
    assert_equal 'D.', auth.first_initial, "Was expecting the middle initial to be 'D.'!"
    assert_equal 'X.', auth.middle_initial, "Was expecting the middle initial to be 'X.'!"
    assert_equal 'D. X. Duck', auth.full_name, "Was expecting the full name to be 'D. X. Duck'!"
  end

  def test_set_last_name
    auth = Cedilla::Author.new({:first_name => 'Daffy'})
    
    auth.last_name = 'Duck'
    assert_equal 'Duck', auth.last_name, "Was expecting the last name to be 'Duck'!"
    assert_equal 'Daffy Duck', auth.full_name, "Was expecting the full name to be 'Daffy Duck'!"
  end

# --------------------------------------------------------------------------------------------------
  def test_last_name_first
    assert_equal 'Doe, John A.', @author.last_name_first, "Was expecting 'Doe, John'!"

    auth = Cedilla::Author.new({:first_name => 'Daffy'})
    assert_equal 'Daffy', auth.last_name_first, "Was expecting 'Daffy'!"
    auth = Cedilla::Author.new({:last_name => 'Duck'})
    assert_equal 'Duck', auth.last_name_first, "Was expecting 'Duck'!"
    auth = Cedilla::Author.new({:first_initial => 'D.'})
    assert_equal 'D.', auth.last_name_first, "Was expecting 'D.'!"
    auth = Cedilla::Author.new({:middle_initial => 'X.'})
    assert_equal nil, auth.last_name_first, "Was expecting ''!"
    auth = Cedilla::Author.new({:initials => 'D. X.'})
    assert_equal 'D. X.', auth.last_name_first, "Was expecting 'D. X.'!"
    
    auth = Cedilla::Author.new({:initials => 'D. X.', :last_name => 'Duck'})
    assert_equal 'Duck, D. X.', auth.last_name_first, "Was expecting 'Duck, D. X.'!"
    auth = Cedilla::Author.new({:middle_initial => 'X.', :last_name => 'Duck'})
    assert_equal 'Duck', auth.last_name_first, "Was expecting 'Duck'!"
    auth = Cedilla::Author.new({:first_initial => 'D.', :last_name => 'Duck'})
    assert_equal 'Duck, D.', auth.last_name_first, "Was expecting 'Duck, D.'!"
    auth = Cedilla::Author.new({:first_name => 'Daffy', :last_name => 'Duck'})
    assert_equal 'Duck, Daffy', auth.last_name_first, "Was expecting 'Duck, Daffy'!"
    auth = Cedilla::Author.new({:middle_initial => 'X.', :last_name => 'Duck', :first_name => 'Daffy'})
    assert_equal 'Duck, Daffy X.', auth.last_name_first, "Was expecting 'Duck, Daffy X.'!"
    
    auth = Cedilla::Author.new({:corporate_author => 'Some organization'})
    assert_equal 'Some organization', auth.last_name_first, "Was expecting 'Some organization'!"
  end

# --------------------------------------------------------------------------------------------------
  def test_to_hash
    hash = @author.to_hash
        
    assert_equal 'John A. Doe', hash['full_name'], "Was expecting the full_name to be 'Doe Jr., John A.'!"
    assert_equal 'Doe', hash['last_name'], "Was expecting the last_name to be 'Doe'!"
    assert_equal 'John', hash['first_name'], "Was expecting the first_name to be 'John'!"
    assert_equal 'Jr.', hash['suffix'], "Was expecting the suffix to be 'Jr.'!"
    assert_equal 'A.', hash['middle_initial'], "Was expecting the middle_initial to be 'A.'!"
    assert_equal 'J.', hash['first_initial'], "Was expecting the first_initial to be 'J.'!"
    assert_equal 'J. A.', hash['initials'], "Was expecting the initials to be 'J. A.'!"
    assert_equal '1900-1980', hash['dates'], "Was expecting the dates to be '1900-1980'!"
    assert_equal 'http://localhost:8080/author/doe/john', hash['authority'], "Was expecting the authority to be 'http://localhost:8080/author/doe/john'!"
    assert_equal 'blah', hash['extras']['foo'][0], "Was expecting the extra, 'foo' to be 'blah!"
    
    hash = @corporate.to_hash

    assert_equal 'Some organization', hash['corporate_author'], "Was expecting the corporate_author to be 'Some organization'!"
  end

end
