require_relative '../test_helper'

class TestAuthor < Test::Unit::TestCase

  def setup
    @author = Cedilla::Author.new({:full_name => 'Doe Jr., John A.', :last_name => 'Doe', :first_name => 'John', :suffix => 'Jr.',
                                   :middle_initial => 'A.', :first_initial => 'J.', :initials => 'J. A.', :junk_val => 'blah'})
  end

# --------------------------------------------------------------------------------------------------
  def test_initialization
    auth = Cedilla::Author.new({:last_name => 'Doe', :first_name => 'John'})
    auth2 = Cedilla::Author.new({:corporate_author => 'The author group'})
    
    assert_equal 'Doe', auth.last_name, "Was expecting the last name to be 'Doe'!"
    assert_equal 'The author group', auth2.corporate_author, "Was expecting the corporate author to be 'The author group'!"
  end
  
# --------------------------------------------------------------------------------------------------
  def test_equality
    # Test invalid match
    auth = Cedilla::Author.new({:last_name => 'Doe', :first_name => 'Jane'})
    assert_not_equal @author, auth, "Was expecting Jane and John Doe's to NOT be equal!"
    
    # Test valid match
    auth = Cedilla::Author.new({:last_name => 'Doe', :first_name => 'John', :middle_initial => 'A.'})
    assert_equal @author, auth, "Was expecting the 2 John Doe's to be equal!"
  end

# --------------------------------------------------------------------------------------------------
  def test_set_first_name
    auth = Cedilla::Author.new({:last_name => 'Jones'})
    
    auth.first_name = 'Barnaby'
    assert_equal 'Barnaby', auth.first_name, "Was expecting the first name to be 'Barnaby'!"
    assert_equal 'B.', auth.first_initial, "Was expecting the first initial to be 'B.'!"
    assert_equal 'Barnaby Jones', auth.full_name, "Was expecting the full name to be 'Barnaby Jones'!"
  end
  
  def test_set_first_initial
    auth = Cedilla::Author.new({:last_name => 'Jones'})
    
    auth.first_initial = 'B.'
    assert_equal 'B.', auth.first_initial, "Was expecting the first initial to be 'B.'!"
    assert_equal 'B. Jones', auth.full_name, "Was expecting the full name to be 'B. Jones'!"
  end
  
  def test_set_middle_initial
    auth = Cedilla::Author.new({:last_name => 'Jones'})
    
    auth.middle_initial = 'X.'
    assert_equal 'X.', auth.middle_initial, "Was expecting the middle initial to be 'X.'!"
    assert_equal 'X. Jones', auth.full_name, "Was expecting the full name to be 'X. Jones'!"
  end
  
  def test_set_initials
    auth = Cedilla::Author.new({:last_name => 'Jones'})
    
    auth.initials = 'B. X.'
    assert_equal 'B. X.', auth.initials, "Was expecting the middle initial to be 'B. X.'!"
    assert_equal 'B.', auth.first_initial, "Was expecting the middle initial to be 'B.'!"
    assert_equal 'X.', auth.middle_initial, "Was expecting the middle initial to be 'X.'!"
    assert_equal 'B. X. Jones', auth.full_name, "Was expecting the full name to be 'B. X. Jones'!"
  end
  
  def test_set_last_name
    auth = Cedilla::Author.new({:first_name => 'Barnaby'})
    
    auth.last_name = 'Jones'
    assert_equal 'Jones', auth.last_name, "Was expecting the last name to be 'Jones'!"
    assert_equal 'Barnaby Jones', auth.full_name, "Was expecting the full name to be 'Barnaby Jones'!"
  end

# --------------------------------------------------------------------------------------------------
  def test_last_name_first
    assert_equal 'Doe, John', @author.last_name_first, "Was expecting 'Doe, John'!"

    auth = Cedilla::Author.new({:first_name => 'Barnaby'})
    assert_equal ', Barnaby', auth.last_name_first, "Was expecting ', Barnaby'!"
    auth = Cedilla::Author.new({:last_name => 'Jones'})
    assert_equal 'Jones', auth.last_name_first, "Was expecting 'Jones'!"
    auth = Cedilla::Author.new({:first_initial => 'B.'})
    assert_equal ', B.', auth.last_name_first, "Was expecting ', B.'!"
    auth = Cedilla::Author.new({:middle_initial => 'X.'})
    assert_equal '', auth.last_name_first, "Was expecting ''!"
    auth = Cedilla::Author.new({:initials => 'B. X.'})
    assert_equal ', B.', auth.last_name_first, "Was expecting ', B.'!"
    
    auth = Cedilla::Author.new({:initials => 'B. X.', :last_name => 'Jones'})
    assert_equal 'Jones, B.', auth.last_name_first, "Was expecting 'Jones, B.'!"
    auth = Cedilla::Author.new({:middle_initial => 'X.', :last_name => 'Jones'})
    assert_equal 'Jones', auth.last_name_first, "Was expecting 'Jones'!"
    auth = Cedilla::Author.new({:first_initial => 'B.', :last_name => 'Jones'})
    assert_equal 'Jones, B.', auth.last_name_first, "Was expecting 'Jones, B.'!"
    auth = Cedilla::Author.new({:first_name => 'Barnaby', :last_name => 'Jones'})
    assert_equal 'Jones, Barnaby', auth.last_name_first, "Was expecting 'Jones, Barnaby'!"
    auth = Cedilla::Author.new({:middle_initial => 'X.', :last_name => 'Jones', :first_name => 'Barnaby'})
    assert_equal 'Jones, Barnaby', auth.last_name_first, "Was expecting 'Jones, Barnaby'!"
    
    auth = Cedilla::Author.from_abritrary_string("Jones, Barnaby X.")
    assert_equal 'Jones, Barnaby', auth.last_name_first, "Was expecting 'Jones, Barnaby'!"
    auth = Cedilla::Author.from_abritrary_string("Barnaby Jones")
    assert_equal 'Jones, Barnaby', auth.last_name_first, "Was expecting 'Jones, Barnaby'!"
  end
  
# --------------------------------------------------------------------------------------------------
  def test_to_hash
    @author.name = "Johnny Doe Jr."
    @author.corporate_author = "The author group"
    
    hash = @author.to_hash
        
    assert_equal 'John A. Doe', hash['full_name'], "Was expecting the genre to be 'Doe Jr., John A.'!"
    assert_equal 'Doe', hash['last_name'], "Was expecting the genre to be 'Doe'!"
    assert_equal 'John', hash['first_name'], "Was expecting the genre to be 'John'!"
    assert_equal 'Jr.', hash['suffix'], "Was expecting the genre to be 'Jr.'!"
    assert_equal 'A.', hash['middle_initial'], "Was expecting the genre to be 'A.'!"
    assert_equal 'J.', hash['first_initial'], "Was expecting the genre to be 'J.'!"
    assert_equal 'J. A.', hash['initials'], "Was expecting the genre to be 'J. A.'!"
    assert_equal 'Johnny Doe Jr.', hash['name'], "Was expecting the genre to be 'Johnny Doe Jr.'!"
    assert_equal 'The author group', hash['corporate_author'], "Was expecting the genre to be 'The author group'!"
    
    assert_equal 'blah', hash['junk_val'], "Was expecting the others to have been included into the hash!"
  end
  
end
