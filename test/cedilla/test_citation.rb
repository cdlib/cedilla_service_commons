require_relative '../test_helper'

class TestCitation < Test::Unit::TestCase

  def setup
    @citation = Cedilla::Citation.new({:genre => 'journal', 
                                       :content_type => 'electronic', 
                                       :subject => 'general', 
                                       :cover_image => 'http://ucop.edu/logo.gif', 
                                       :abstract => 'This is a short description of the item', 
                                       :issn => '0378-5955', 
                                       :eissn => '2434-561X', 
                                       :isbn_10 => '817525766-0',
                                       :eisbn_10 => '0-440-18293-X',
                                       :isbn_13 => '9 788175 257668',
                                       :eisbn_13 => '978-1-93435-608-1', 
                                       :oclc => 'ocm123456789', 
                                       :lccn => '2004-00123', 
                                       :doi => '10.1000/182', 
                                       :pmid => '6996886',
                                       :coden => 'NATUAS',
                                       :sici => '0378-5955(199412)45:10<737:TIODIM>2.3.TX;2-M',
                                       :bici => '817525766-0(199412)45:10<737:TIODIM>2.3.TX;2-M',
                                       :dissertation_id => '1234567890ABC',
                                       :title => 'Example Title', 
                                       :journal_title => 'Some <escape me> \ Journal', :article_title => 'Good Article',
                                       :book_title => 'Book title', :chapter_title => 'Chapter Seven',
                                       :series_title => 'Series title',
                                       :short_titles => ['Ex.', 'Example'], 
                                       :publisher => 'Bargain Books', :publication_date => '2010', :publication_place => 'New York', 
                                       :date => '2010', :year => '2010', :month => '03', :day => '12', 
                                       :season => 'Spring', :quarter => '1st', :institute => 'My institute',
                                       :volume => '23', :issue => '1', :article_number => '34', :enumeration => 'v. 23 - 1', 
                                       :part => '?', :edition => '2nd', :series => '13-56', :text_language => 'french',
                                       :start_page => '34', :end_page => '45', :pages => '34-45',
                                       :who => 'who?', :what => 'what?', :when => 'when', :where => 'where', :why => 'why',
                                       :authors => [Cedilla::Author.new({:last_name => 'Doe', :first_name => 'John'}),
                                                    Cedilla::Author.new({:last_name => 'Smith', :first_initial => 'B.'})],
                                       :resources => [Cedilla::Resource.new({:source => 'test 1', :target => 'blah blah'}),
                                                      Cedilla::Resource.new({:source => 'test 2', :target => 'blah blah blah'})]
                                      })
  end

# --------------------------------------------------------------------------------------------------------  
  def test_initialization
    citation = Cedilla::Citation.new({})
    assert citation.resources.empty?, "Was expecting the citation's resources to be initialized to an empty Set!"
    assert citation.authors.empty?, "Was expecting the citation's authors property to be initialized to an empty Set!"
    assert citation.short_titles.empty?, "Was expecting the citation's short titles property to be initialized to an empty array!"
    assert citation.others.empty?, "Was expecting the citation's others property to be initialized to an empty Set!"
  end

# --------------------------------------------------------------------------------------------------------    
  def test_equality
    a = Cedilla::Citation.new({:genre => 'book', :content_type => 'full_text', :issn => '1234-1234'})
    b = Cedilla::Citation.new({:genre => 'journal', :content_type => 'purchase', :isbn => '1234567890'})
    c = Cedilla::Citation.new({:genre => 'book', :content_type => 'full_text', :issn => '1234-1234'})
    d = Cedilla::Citation.new({:genre => 'book', :content_type => 'full_text', :issn => '1234-1234', :author_last_name => 'Doe'})
    e = Cedilla::Citation.new({:genre => 'book', :content_type => 'full_text', :issn => '1234-1234', :title => 'Example title'})
    f = Cedilla::Citation.new({:genre => 'book', :content_type => 'full_text', :issn => '1234-123x', :title => 'Example title'})
    
    assert a != b, "Was expecting 2 different citations to evaluate to False!"
    assert a == c, "Was expecting 2 identical citations to evaluate to True!"
    assert a == d, "Was expecting 2 similar citations to evaluate to True!"
    assert a == e, "Was expecting 2 citations with different titles but the same issn to be True!"
    assert e != f, "Was expecting 2 citations with different issns but the same title to be False!"
  end
  
# --------------------------------------------------------------------------------------------------------    
  def test_valid
    # No genre or content type - should fail
    assert !Cedilla::Citation.new.valid?, "An empty citation should not pass the validation check!"
    
    # No genre - should fail
    assert !Cedilla::Citation.new({:content_type => 'electronic'}).valid?, "A citation with no genre should not pass the validation check!"
    
    # No content type - should fail
    assert !Cedilla::Citation.new({:genre => 'journal'}).valid?, "A citation with no content type should not pass the validation check!"
    
    # genre and content type - should pass
    assert Cedilla::Citation.new({:genre => 'journal', :content_type => 'electronic'}).valid?, "A citation with a genre and content type should pass the validation check!"
    
    # bogus genre should fail
    assert !Cedilla::Citation.new({:genre => 'bogus', :content_type => 'electronic'}).valid?, "A citation with a bogus genre should not pass the validation check!"
    
    # bogus content_type should fail
    assert !Cedilla::Citation.new({:genre => 'journal', :content_type => 'bogus'}).valid?, "A citation with a bogus content type should not pass the validation check!"
  end
  
# --------------------------------------------------------------------------------------------------------  
  def test_has_identifier
    # Test that it returns false when it has no identifiers
    assert !Cedilla::Citation.new({}).has_identifier?, "Expected there to be no identifiers for an empty citation!"
    assert !Cedilla::Citation.new({:genre => 'journal', :content_type => 'electronic'}).has_identifier?, "Expected there to be no identifiers with just genre and content type defined!"
    assert !Cedilla::Citation.new({:genre => 'journal', :content_type => 'electronic', :title => 'blah'}).has_identifier?, "Expected there to be no identifiers with just genre and content type defined!"
    
    # Test the various identifiers to make sure they were each assigned in the setup step
    assert !@citation.issn.nil?, "Expected there to be an ISSN!"
    assert !@citation.eissn.nil?, "Expected there to be an EISSN!"
    assert !@citation.isbn_10.nil?, "Expected there to be an ISBN-10!"
    assert !@citation.eisbn_10.nil?, "Expected there to be an E-ISBN-10!"
    assert !@citation.isbn_13.nil?, "Expected there to be an ISBN-13!"
    assert !@citation.eisbn_13.nil?, "Expected there to be an E-ISBN-13!"
    assert !@citation.doi.nil?, "Expected there to be a DOI!"
    assert !@citation.oclc.nil?, "Expected there to be an OCLC Id!"
    assert !@citation.lccn.nil?, "Expected there to be a LCCN!"
    assert !@citation.pmid.nil?, "Expected there to be a PubMed Id (PMID)!"
    assert !@citation.coden.nil?, "Expected there to be a CODEN!"
    assert !@citation.sici.nil?, "Expected there to be a SICI!"
    assert !@citation.bici.nil?, "Expected there to be a BICI!"
    assert !@citation.dissertation_id.nil?, "Expected there to be a Disertation Id!"
    
    # Test that it returns true when it has multiple identifiers
    assert @citation.has_identifier?, "Expected citation to confirm an identifier exists when multiple identifiers are defined!"
  end

# --------------------------------------------------------------------------------------------------------  
  def test_has_resource
    assert !@citation.has_resource?(Cedilla::Resource.new({:source => 'abcd', :location => 'xyz'})), "Was expecting the citation to NOT have this resource!"
    
    assert @citation.has_resource?(Cedilla::Resource.new({:source => 'test 1', :target => 'blah blah'})), "Was expecting the citation to have this resource!"
  end

# --------------------------------------------------------------------------------------------------------  
  def test_has_author
    assert !@citation.has_author?(Cedilla::Author.new({:name => 'xyz'})), "Was expecting the citation to NOT have this author!"
    
    assert @citation.has_author?(Cedilla::Author.new({:full_name => 'John Doe'})), "Was expecting the citation to have this author!"
  end
   
# --------------------------------------------------------------------------------------------------------  
  def test_get_identifiers
    # Test to make sure that the identifiers are empty when they should be
    assert !Cedilla::Citation.new({}).identifiers.collect{ |x,y| !y.nil? }.include?(true), "Expected there to be no identifiers for an empty citation!"
    assert !Cedilla::Citation.new({:genre => 'journal', :content_type => 'electronic'}).identifiers.collect{ |x,y| !y.nil? }.include?(true), "Expected there to be no identifiers with just genre and content type defined!"
    assert !Cedilla::Citation.new({:genre => 'journal', :content_type => 'electronic', :title => 'blah'}).identifiers.collect{ |x,y| !y.nil? }.include?(true), "Expected there to be no identifiers with just genre and content type defined!"
    
    # Test the various identifiers to make sure they were each assigned in the setup step
    assert !@citation.identifiers['issn'].nil?, "Expected there to be an ISSN!"
    assert !@citation.identifiers['eissn'].nil?, "Expected there to be an EISSN!"
    assert !@citation.identifiers['isbn_10'].nil?, "Expected there to be an ISBN-10!"
    assert !@citation.identifiers['eisbn_10'].nil?, "Expected there to be an E-ISBN-10!"
    assert !@citation.identifiers['isbn_13'].nil?, "Expected there to be an ISBN-13!"
    assert !@citation.identifiers['eisbn_13'].nil?, "Expected there to be an E-ISBN-13!"
    assert !@citation.identifiers['doi'].nil?, "Expected there to be a DOI!"
    assert !@citation.identifiers['oclc'].nil?, "Expected there to be an OCLC Id!"
    assert !@citation.identifiers['lccn'].nil?, "Expected there to be a LCCN!"
    assert !@citation.identifiers['pmid'].nil?, "Expected there to be a PubMed Id (PMID)!"
    assert !@citation.identifiers['coden'].nil?, "Expected there to be a CODEN!"
    assert !@citation.identifiers['sici'].nil?, "Expected there to be a SICI!"
    assert !@citation.identifiers['bici'].nil?, "Expected there to be a BICI!"
    assert !@citation.identifiers['dissertation_id'].nil?, "Expected there to be a Disertation Id!"
    
    assert_equal 14, @citation.identifiers.size, "Was expecting 14 identifiers to have been set!"
  end 
  
# --------------------------------------------------------------------------------------------------------  
  def test_set_isbn
    citation = Cedilla::Citation.new({:genre => 'journal', :content_type => 'electronic'})
    
    # Make sure it sets the 10
    citation.isbn = '817525766-0'
    assert_equal '817525766-0', citation.isbn_10, "Was expecting the ISBN-10 to be set!"
    citation.isbn_10 = nil
    
    # Make sure it sets the 13
    citation.isbn = '9 788175 257668'
    assert_equal '9 788175 257668', citation.isbn_13, "Was expecting the ISBN-13 to be set!"
    citation.isbn_13 = nil
    
    # Make sure that both the 10 and 13 lengths are set
    citation.isbn = '817525766-0'
    citation.isbn = '9 788175 257668'
    assert_equal '817525766-0', citation.isbn_10, "Was expecting the ISBN-10 to be set when both were tried!"
    assert_equal '9 788175 257668', citation.isbn_13, "Was expecting the ISBN-13 to be set when both were tried!"
    citation.isbn_10 = nil
    citation.isbn_13 = nil
    
    # Make sure it sets the 10 when the value is bad
    citation.isbn = '81752'
    assert_equal '81752', citation.isbn_10, "Was expecting the ISBN-10 to be set by default when the value is bad!"
  end
  
# --------------------------------------------------------------------------------------------------------  
  def test_get_isbn
    citation = Cedilla::Citation.new({:genre => 'journal', :content_type => 'electronic'})
    
    # Make sure it sets the 10
    citation.isbn_10 = '2434-561X'
    assert_equal '2434-561X', citation.isbn, "Was expecting the ISBN-10 to be returned!"
    citation.isbn_10 = nil
    
    # Make sure it sets the 13
    citation.isbn_13 = '978-1-93435-608-1'
    assert_equal '978-1-93435-608-1', citation.isbn, "Was expecting the ISBN-13 to be returned!"
    citation.isbn_13 = nil
    
    # Make sure that both the 10 and 13 lengths are set
    citation.isbn_10 = '2434-561X'
    citation.isbn_13 = '978-1-93435-608-1'
    assert_equal '2434-561X', citation.isbn, "Was expecting the ISBN-13 to be returned when both were present!"
  end
  
# --------------------------------------------------------------------------------------------------------  
  def test_set_eisbn
    citation = Cedilla::Citation.new({:genre => 'journal', :content_type => 'electronic'})
    
    # Make sure it sets the 10
    citation.eisbn = '2434-561X'
    assert_equal '2434-561X', citation.eisbn_10, "Was expecting the E-ISBN-10 to be set!"
    citation.eisbn_10 = nil
    
    # Make sure it sets the 13
    citation.eisbn = '978-1-93435-608-1'
    assert_equal '978-1-93435-608-1', citation.eisbn_13, "Was expecting the E-ISBN-13 to be set!"
    citation.eisbn_13 = nil
    
    # Make sure that both the 10 and 13 lengths are set
    citation.eisbn = '2434-561X'
    citation.eisbn = '978-1-93435-608-1'
    assert_equal '2434-561X', citation.eisbn_10, "Was expecting the E-ISBN-10 to be set when both were tried!"
    assert_equal '978-1-93435-608-1', citation.eisbn_13, "Was expecting the E-ISBN-13 to be set when both were tried!"
    citation.eisbn_10 = nil
    citation.eisbn_13 = nil
    
    # Make sure it sets the 10 when the value is bad
    citation.eisbn = '2434'
    assert_equal '2434', citation.eisbn_10, "Was expecting the E-ISBN-10 to be set by default when the value is bad!"
  end

# --------------------------------------------------------------------------------------------------------    
  def test_get_eisbn
    citation = Cedilla::Citation.new({:genre => 'journal', :content_type => 'electronic'})
    
    # Make sure it sets the 10
    citation.eisbn_10 = '2434-561X'
    assert_equal '2434-561X', citation.eisbn, "Was expecting the E-ISBN-10 to be returned!"
    citation.eisbn_10 = nil
    
    # Make sure it sets the 13
    citation.eisbn_13 = '978-1-93435-608-1'
    assert_equal '978-1-93435-608-1', citation.eisbn, "Was expecting the E-ISBN-13 to be returned!"
    citation.eisbn_13 = nil
    
    # Make sure that both the 10 and 13 lengths are set
    citation.eisbn_10 = '2434-561X'
    citation.eisbn_13 = '978-1-93435-608-1'
    assert_equal '2434-561X', citation.eisbn, "Was expecting the E-ISBN-10 to be returned when both were present!"
  end
  
# --------------------------------------------------------------------------------------------------------  
  def test_set_genre
    # Test bad genre has error
    citation = Cedilla::Citation.new({:genre => 'blah', :content_type => 'electronic'})
    #assert !citation.errors[:genre].nil?, "Was expecting there to be a genre error!"
    
    # Test good genre
    citation.genre = 'journal'
    assert_equal 'journal', citation.genre, "Was expecting there to be no errors after setting a good genre!"
  end

# --------------------------------------------------------------------------------------------------------    
  def test_set_content_type
    # Test bad content_type has error
    citation = Cedilla::Citation.new({:genre => 'journal', :content_type => 'blah'})
    #assert !citation.errors[:content_type].nil?, "Was expecting there to be a content_type error!"
    
    # Test good content_type
    citation.content_type = 'electronic'
    assert_equal 'electronic', citation.content_type, "Was expecting there to be no errors after setting a good content_type!"
  end
  
# --------------------------------------------------------------------------------------------------------  
  def test_to_hash
    hash = @citation.to_hash
    #hash: {"genre"=>"journal", "content_type"=>"electronic", "subject"=>"general", "cover_image"=>"http://ucop.edu/logo.gif", 
    #       "abstract"=>"This is a short description of the item", "text_language"=>"french", "issn"=>"0378-5955", 
    #       "eissn"=>"2434-561X", "isbn_10"=>"817525766-0", "eisbn_10"=>"0-440-18293-X", "isbn_13"=>"9 788175 257668", 
    #       "eisbn_13"=>"978-1-93435-608-1", "oclc"=>"ocm123456789", "lccn"=>"2004-00123", "doi"=>"10.1000/182", 
    #       "pmid"=>"6996886", "coden"=>"NATUAS", "sici"=>"0378-5955(199412)45:10<737:TIODIM>2.3.TX;2-M", 
    #       "bici"=>"817525766-0(199412)45:10<737:TIODIM>2.3.TX;2-M", "dissertation_id"=>"1234567890ABC", 
    #       "title"=>"Example Title", "article_title"=>"Good Article", "journal_title"=>"Some <escape me> \\ Journal", 
    #       "chapter_title"=>"Chapter Seven", "book_title"=>"Book title", "series_title"=>"Series title", 
    #       "publisher"=>"Bargain Books", "publication_date"=>"2010", "publication_place"=>"New York", "date"=>"2010", 
    #       "year"=>"2010", "month"=>"03", "day"=>"12", "season"=>"Spring", "quarter"=>"1st", "volume"=>"23", "issue"=>"1", 
    #       "article_number"=>"34", "enumeration"=>"v. 23 - 1", "part"=>"?", "edition"=>"2nd", "institute"=>"Myinstitute", 
    #       "series"=>"13-56", "start_page"=>"34", "end_page"=>"45", "pages"=>"34-45", "isbn"=>"817525766-0", "eisbn"=>"0-440-18293-X", 
    #       "short_titles"=>"Ex.", "who"=>"who?", "what"=>"what?", "when"=>"when", "where"=>"where", "why"=>"why", 
    #       "authors"=>[{"full_name"=>"John Doe", "last_name"=>"Doe", "first_name"=>"John", "first_initial"=>"J.", "initials"=>"J."}, {"full_name"=>"B. Smith", "last_name"=>"Smith", "first_initial"=>"B.", "initials"=>"B."}], 
    #       "resources"=>[{"source"=>"test 1", "target"=>"blah blah", "availability"=>false}, {"source"=>"test 2", "target"=>"blah blah blah", "availability"=>false}]}.
    
    assert_equal 'journal', hash['genre'], "Was expecting the genre to be 'journal'!"
    assert_equal 'electronic', hash['content_type'], "Was expecting the content_type to be 'electronic'!"
    assert_equal 'general', hash['subject'], "Was expecting the subject to be 'genral'!"
    assert_equal 'http://ucop.edu/logo.gif', hash['cover_image'], "Was expecting the cover image to be 'http://ucop.edu/logo.gif'!"
    assert_equal 'This is a short description of the item', hash['abstract'], "Was expecting the abstract to be 'This is a short description of the item'!"
    
    assert_equal '0378-5955', hash['issn'], "Was expecting the issn to be '0378-5955'!"
    assert_equal '2434-561X', hash['eissn'], "Was expecting the eissn to be '2434-561X'!"
    assert_equal '817525766-0', hash['isbn_10'], "Was expecting the isbn-10 to be '817525766-0'!"
    assert_equal '0-440-18293-X', hash['eisbn_10'], "Was expecting the eisbn-10 to be '0-440-18293-X'!"
    assert_equal '9 788175 257668', hash['isbn_13'], "Was expecting the isbn-13 to be '9 788175 257668'!"
    assert_equal '978-1-93435-608-1', hash['eisbn_13'], "Was expecting the eisbn-13 to be '978-1-93435-608-1'!"
    assert_equal 'ocm123456789', hash['oclc'], "Was expecting the oclc to be 'ocm123456789'!"
    assert_equal '2004-00123', hash['lccn'], "Was expecting the lccn to be '2004-00123'!"
    assert_equal '10.1000/182', hash['doi'], "Was expecting the doi to be '10.1000/182'!"
    assert_equal '6996886', hash['pmid'], "Was expecting the svc_specific_id_1 to be '6996886'!"
    assert_equal 'NATUAS', hash['coden'], "Was expecting the svc_specific_id_2 to be 'NATUAS'!"
    assert_equal '0378-5955(199412)45:10<737:TIODIM>2.3.TX;2-M', hash['sici'], "Was expecting the svc_specific_id_3 to be '0378-5955(199412)45:10<737:TIODIM>2.3.TX;2-M'!"
    assert_equal '817525766-0(199412)45:10<737:TIODIM>2.3.TX;2-M', hash['bici'], "Was expecting the svc_specific_id_2 to be '817525766-0(199412)45:10<737:TIODIM>2.3.TX;2-M'!"
    assert_equal '1234567890ABC', hash['dissertation_id'], "Was expecting the svc_specific_id_2 to be '1234567890ABC'!"
    
    assert_equal 'Example Title', hash['title'], "Was expecting the title to be 'Example Title'!"
    assert_equal 'Good Article', hash['article_title'], "Was expecting the article title to be 'Good Article'!"
    assert_equal 'Some <escape me> \ Journal', hash['journal_title'], "Was expecting the journal title to be 'Some <escape me> \ Journal'!"
    assert_equal 'Series title', hash['series_title'], "Was expecting the series title to be 'Series title'!"
    assert_equal 'Book title', hash['book_title'], "Was expecting the book title to be 'Book title'!"
    assert_equal 'Chapter Seven', hash['chapter_title'], "Was expecting the chapter title to be 'Chapter Seven'!"
    assert_equal 'Ex.', hash['short_titles'], "Was expecting the receive the first item, 'Ex.' from the short titles array!"
    
    assert_equal 'Bargain Books', hash['publisher'], "Was expecting the publisher to be 'Bargain Books'!"
    assert_equal '2010', hash['publication_date'], "Was expecting the publication date to be '2010'!"
    assert_equal 'New York', hash['publication_place'], "Was expecting the publication place to be 'New York'!"
    
    assert_equal '2010', hash['date'], "Was expecting the date to be '2010'!"
    assert_equal '2010', hash['year'], "Was expecting the year to be '2010'!"
    assert_equal '03', hash['month'], "Was expecting the month to be '03'!"
    assert_equal '12', hash['day'], "Was expecting the day to be '12'!"
    assert_equal '23', hash['volume'], "Was expecting the volume to be '23'!"
    assert_equal '1', hash['issue'], "Was expecting the issue to be '1'!"
    assert_equal 'My institute', hash['institute'], "Was expecting the institute to be 'My institute'!"
    assert_equal '13-56', hash['series'], "Was expecting the series to be '13-56'!"
    assert_equal '34', hash['article_number'], "Was expecting the article number to be '34'!"
    assert_equal 'v. 23 - 1', hash['enumeration'], "Was expecting the enumeration to be 'v. 23 - 1'!"
    assert_equal 'Spring', hash['season'], "Was expecting the season to be 'Spring'!"
    assert_equal '1st', hash['quarter'], "Was expecting the quarter to be '1st'!"
    assert_equal '?', hash['part'], "Was expecting the part to be '?'!"
    assert_equal '2nd', hash['edition'], "Was expecting the edition to be '2nd'!"
    assert_equal 'french', hash['text_language'], "Was expecting the language to be 'french'!"
    
    assert_equal '34', hash['start_page'], "Was expecting the start page to be '34'!"
    assert_equal '45', hash['end_page'], "Was expecting the end page to be '45'!"
    assert_equal '34-45', hash['pages'], "Was expecting the pages to be '34-45'!"
    
    assert_equal 'what?', hash['what'], "Was expecting the others array to have been included in the hash!"
    
    first_author = hash['authors'].first
    assert_equal 'Doe', first_author['last_name'], "Was expecting the others array to have been included in the hash!"
  end
  
  # --------------------------------------------------------------------------------------------------------  
  def test_get_authors
    assert !@citation.authors.empty?, "Was expecting there were authors"
    assert_equal 2, @citation.authors.size, "Was expecting there were two authors"
    assert_equal 'Doe', @citation.authors.first.last_name, "Was expecting the first author's last name to be 'Doe'!"
    
    citation = Cedilla::Citation.new({:genre => 'book', :content_type => 'electronic', :title => 'The Metamorphosis', :date => '2014', 
                                      :authors => [{:last_name => 'Dickens', :first_initial => 'B.'}, {:last_name => 'Kafka', :first_name => 'Franz'}]})
    assert_equal 2, citation.authors.size, "Was expecting there were two authors"
    assert_equal 'Dickens', citation.authors.first.last_name, "Was expecting the first author's last name to be 'Dickens'!"
  end
  
  # --------------------------------------------------------------------------------------------------------  
  def test_get_resources
    resources = @citation.resources  # getting the resources
    assert !@citation.resources.empty?, "Was expecting there were resources"
    assert_equal 2, @citation.resources.size, "Was expecting there were two resources"
    @citation.resources.first.target = 'http://www.ucop.edu/link/to/item'

    citation = Cedilla::Citation.new({:genre => 'book', :content_type => 'electronic', :title => 'The Metamorphosis', :date => '2014', 
                                      :resources => [{:source => 'source 1', :location => 'location 1'}, {:source => 'source 2', :target => 'http://www.ucop.edu/link/to/item'}]})
    assert_equal 'source 1', citation.resources.first.source, "Was expecting the first resource's source to be 'source 1'!"
  end
end