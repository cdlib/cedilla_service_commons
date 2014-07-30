require_relative '../test_helper'

class TestCitation < MiniTest::Test

  def setup
    @citation = Cedilla::Citation.new({:genre => 'article', 
                                       :issn => '0378-5955', 
                                       :eissn => '2434-561X', 
                                       :isbn => '817525766-0',
                                       :eisbn => '0-440-18293-X',
                                       :oclc => 'ocm123456789', 
                                       :lccn => '2004-00123', 
                                       :doi => '10.1000/182', 
                                       :pmid => '6996886',
                                       :coden => 'NATUAS',
                                       :sici => '0378-5955(199412)45:10<737:TIODIM>2.3.TX;2-M',
                                       :bici => '817525766-0(199412)45:10<737:TIODIM>2.3.TX;2-M',
                                       :document_id => '12345',
                                       :bibcode => '2014MNRAS..84..308E',
                                       :eric => 'ED358673',
                                       :oai => 'oai:foo.org:some-local-id-53',
                                       :nbn => 'nbn:ch:bel-9596',
                                       :hdl => 'hdl:loc:pnp/cph.3c30104',
                                       :dissertation_number => '1234567890ABC',
                                       :title => 'Example Title', 
                                       :journal_title => 'Some <escape me> \ Journal', :article_title => 'Good Article',
                                       :book_title => 'Book title', :chapter_title => 'Chapter Seven',
                                       :short_title => ['Ex.', 'Example'], 
                                       :publisher => 'Bargain Books', :publication_date => '2010', :publication_place => 'New York', 
                                       :year => '2010', :month => '03', :day => '15', 
                                       :season => 'Spring', :quarter => '1st', :institution => 'My institute',
                                       :volume => '23', :issue => '1', :article_number => '34', :enumeration => 'v. 23 - 1', 
                                       :part => '?', :edition => '2nd', :series => '13-56', 
                                       :start_page => '34', :end_page => '45', :pages => '34-45',
                                       :subject => ['history', 'american history', 'HIST'],
                                       :sample_cover_image => 'http://some.site.org/link/to/image/cover.jpg',
                                       :abstract_text => 'This is a brief synopsis of the item ... blah blah blah',
                                       :language => 'English',
                                       :who => 'who?', :what => 'what?', :when => 'when', :where => 'where', :why => 'why',
                                       :authors => [Cedilla::Author.new({:last_name => 'Doe', :first_name => 'John'}),
                                                    Cedilla::Author.new({:last_name => 'Smith', :first_initial => 'B.'})],
                                       :resources => [Cedilla::Resource.new({:source => 'test 1', :target => 'blah blah'}),
                                                      Cedilla::Resource.new({:source => 'test 2', :target => 'blah blah blah'})]
                                      })
  end  

# --------------------------------------------------------------------------------------------------------  
  def test_initialization
    # Test worng number of parameters
    assert_raises(ArgumentError){ Cedilla::Citation.new() }
    assert_raises(ArgumentError){ Cedilla::Citation.new(1, 2) }
    
    # Test not a hash
    assert_raises(ArgumentError){ Cedilla::Citation.new(nil) }
    assert_raises(ArgumentError){ Cedilla::Citation.new('123') }
    assert_raises(ArgumentError){ Cedilla::Citation.new(123) }
    assert_raises(ArgumentError){ Cedilla::Citation.new(['bar','123']) }
    
    # Test that all defaults are set
    citation = Cedilla::Citation.new({})
    assert citation.resources.empty?, "Was expecting the citation's resources to be initialized to an empty Set!"
    assert citation.authors.empty?, "Was expecting the citation's authors property to be initialized to an empty Set!"
    assert citation.short_title.nil?, "Was expecting the citation's short titles property to be initialized to an empty array!"
    assert citation.extras.empty?, "Was expecting the citation's others property to be initialized to an empty Set!"
    
    # Test full item
    assert_equal 'article', @citation.genre, "Was expecting the genre to be set!"
    assert_equal '0378-5955', @citation.issn, "Was expecting the issn to be set!"
    assert_equal '2434-561X', @citation.eissn, "Was expecting the eissn to be set!"
    assert_equal '817525766-0', @citation.isbn, "Was expecting the isbn to be set!"
    assert_equal '0-440-18293-X', @citation.eisbn, "Was expecting the eisbn to be set!"
    assert_equal 'ocm123456789', @citation.oclc, "Was expecting the oclc to be set!"
    assert_equal '2004-00123', @citation.lccn, "Was expecting the lccn to be set!"
    assert_equal '10.1000/182', @citation.doi, "Was expecting the doi to be set!"
    assert_equal '6996886', @citation.pmid, "Was expecting the pmid to be set!"
    assert_equal 'NATUAS', @citation.coden, "Was expecting the coden to be set!"
    assert_equal '0378-5955(199412)45:10<737:TIODIM>2.3.TX;2-M', @citation.sici, "Was expecting the genre to be set!"
    assert_equal '817525766-0(199412)45:10<737:TIODIM>2.3.TX;2-M', @citation.bici, "Was expecting the genre to be set!"
    assert_equal '12345', @citation.document_id, "Was expecting the genre to be set!"
    assert_equal '2014MNRAS..84..308E', @citation.bibcode, "Was expecting the bibcode to be set!"
    assert_equal 'ED358673', @citation.eric, "Was expecting the eric to be set!"
    assert_equal 'oai:foo.org:some-local-id-53', @citation.oai, "Was expecting the oai to be set!"
    assert_equal 'nbn:ch:bel-9596', @citation.nbn, "Was expecting the nbn to be set!"
    assert_equal 'hdl:loc:pnp/cph.3c30104', @citation.hdl, "Was expecting the hdl to be set!"
    assert_equal '1234567890ABC', @citation.dissertation_number, "Was expecting the dissertation_number to be set!"
    assert_equal 'Example Title', @citation.title, "Was expecting the title to be set!"
    assert_equal 'Some <escape me> \ Journal', @citation.journal_title, "Was expecting the journal_title to be set!"
    assert_equal 'Good Article', @citation.article_title, "Was expecting the article_title to be set!"
    assert_equal 'Book title', @citation.book_title, "Was expecting the book_title to be set!"
    assert_equal 'Chapter Seven', @citation.chapter_title, "Was expecting the chapter_title to be set!"
    assert_equal ['Ex.', 'Example'], @citation.short_title, "Was expecting the short_title to be set!"
    assert_equal 'Bargain Books', @citation.publisher, "Was expecting the publisher to be set!"
    assert_equal '2010', @citation.publication_date, "Was expecting the publication_date to be set!"
    assert_equal 'New York', @citation.publication_place, "Was expecting the publication_place to be set!"
    assert_equal '2010', @citation.year, "Was expecting the year to be set!"
    assert_equal '03', @citation.month, "Was expecting the month to be set!"
    assert_equal '15', @citation.day, "Was expecting the day to be set!"
    assert_equal 'Spring', @citation.season, "Was expecting the season to be set!"
    assert_equal '1st', @citation.quarter, "Was expecting the quarter to be set!"
    assert_equal 'My institute', @citation.institution, "Was expecting the institute to be set!"
    assert_equal '23', @citation.volume, "Was expecting the volume to be set!"
    assert_equal '1', @citation.issue, "Was expecting the issue to be set!"
    assert_equal '34', @citation.article_number, "Was expecting the article_number to be set!"
    assert_equal 'v. 23 - 1', @citation.enumeration, "Was expecting the enumeration to be set!"
    assert_equal '?', @citation.part, "Was expecting the part to be set!"
    assert_equal '2nd', @citation.edition, "Was expecting the edition to be set!"
    assert_equal '13-56', @citation.series, "Was expecting the series to be set!"
    assert_equal '34', @citation.start_page, "Was expecting the start_page to be set!"
    assert_equal '45', @citation.end_page, "Was expecting the end_page to be set!"
    assert_equal '34-45', @citation.pages, "Was expecting the pages to be set!"
    assert_equal ['history', 'american history', 'HIST'], @citation.subject, "Was expecting the subject to be set!"
    assert_equal 'http://some.site.org/link/to/image/cover.jpg', @citation.sample_cover_image, "Was expecting the sample_cover_image to be set!"
    assert_equal 'This is a brief synopsis of the item ... blah blah blah', @citation.abstract_text, "Was expecting the abstract_text to be set!"
    assert_equal 'English', @citation.language, "Was expecting the language to be set!"
    
    assert_equal 5, @citation.extras.count, "Was expecting 5 extras!"
    assert_equal 'who?', @citation.extras['who'][0], "Was expecting an extra named 'who' to be set!"
    assert_equal 'when', @citation.extras['when'][0], "Was expecting an extra named 'when' to be set!"
    
    assert_equal 2, @citation.authors.count, "Was expecting 2 authors!"
    assert_equal 2, @citation.resources.count, "Was expecting 2 resources!"
  end

# --------------------------------------------------------------------------------------------------------    
  def test_equality
    a = Cedilla::Citation.new({:genre => 'book', :issn => '1234-1234'})
    b = Cedilla::Citation.new({:genre => 'journal', :issn => '0378-5955'})
    assert a != b, "Was expecting a to not equal b because the issns do not match"
    assert a != @citation, "Was expecting a to not equal @citation because the issns do not match"
    assert b == @citation, "Was expecting b to equal @citation because the issns match"
    
    a = Cedilla::Citation.new({:genre => 'book', :eissn => '1234-1234'})
    b = Cedilla::Citation.new({:genre => 'journal', :eissn => '2434-561X'})
    assert a != b, "Was expecting a to not equal b because the eissns do not match"
    assert a != @citation, "Was expecting a to not equal @citation because the eissns do not match"
    assert b == @citation, "Was expecting b to equal @citation because the eissns match"
    
    a = Cedilla::Citation.new({:genre => 'book', :isbn => '1234-1234'})
    b = Cedilla::Citation.new({:genre => 'journal', :isbn => '817525766-0'})
    assert a != b, "Was expecting a to not equal b because the isbns do not match"
    assert a != @citation, "Was expecting a to not equal @citation because the isbns do not match"
    assert b == @citation, "Was expecting b to equal @citation because the isbns match"
    
    a = Cedilla::Citation.new({:genre => 'book', :eisbn => '1234-1234'})
    b = Cedilla::Citation.new({:genre => 'journal', :eisbn => '0-440-18293-X'})
    assert a != b, "Was expecting a to not equal b because the eisbns do not match"
    assert a != @citation, "Was expecting a to not equal @citation because the eisbns do not match"
    assert b == @citation, "Was expecting b to equal @citation because the eisbns match"
    
    a = Cedilla::Citation.new({:genre => 'book', :oclc => '1234-1234'})
    b = Cedilla::Citation.new({:genre => 'journal', :oclc => 'ocm123456789'})
    assert a != b, "Was expecting a to not equal b because the oclcs do not match"
    assert a != @citation, "Was expecting a to not equal @citation because the oclcs do not match"
    assert b == @citation, "Was expecting b to equal @citation because the oclcs match"
    
    a = Cedilla::Citation.new({:genre => 'book', :lccn => '1234-1234'})
    b = Cedilla::Citation.new({:genre => 'journal', :lccn => '2004-00123'})
    assert a != b, "Was expecting a to not equal b because the lccns do not match"
    assert a != @citation, "Was expecting a to not equal @citation because the lccns do not match"
    assert b == @citation, "Was expecting b to equal @citation because the lccns match"
    
    a = Cedilla::Citation.new({:genre => 'book', :doi => '1234-1234'})
    b = Cedilla::Citation.new({:genre => 'journal', :doi => '10.1000/182'})
    assert a != b, "Was expecting a to not equal b because the dois do not match"
    assert a != @citation, "Was expecting a to not equal @citation because the dois do not match"
    assert b == @citation, "Was expecting b to equal @citation because the dois match"
    
    a = Cedilla::Citation.new({:genre => 'book', :pmid => '1234-1234'})
    b = Cedilla::Citation.new({:genre => 'journal', :pmid => '6996886'})
    assert a != b, "Was expecting a to not equal b because the pmids do not match"
    assert a != @citation, "Was expecting a to not equal @citation because the pmids do not match"
    assert b == @citation, "Was expecting b to equal @citation because the pmids match"
    
    a = Cedilla::Citation.new({:genre => 'book', :coden => '1234-1234'})
    b = Cedilla::Citation.new({:genre => 'journal', :coden => 'NATUAS'})
    assert a != b, "Was expecting a to not equal b because the codens do not match"
    assert a != @citation, "Was expecting a to not equal @citation because the codens do not match"
    assert b == @citation, "Was expecting b to equal @citation because the codens match"
    
    a = Cedilla::Citation.new({:genre => 'book', :sici => '1234-1234'})
    b = Cedilla::Citation.new({:genre => 'journal', :sici => '0378-5955(199412)45:10<737:TIODIM>2.3.TX;2-M'})
    assert a != b, "Was expecting a to not equal b because the sicis do not match"
    assert a != @citation, "Was expecting a to not equal @citation because the sicis do not match"
    assert b == @citation, "Was expecting b to equal @citation because the sicis match"
    
    a = Cedilla::Citation.new({:genre => 'book', :bici => '1234-1234'})
    b = Cedilla::Citation.new({:genre => 'journal', :bici => '817525766-0(199412)45:10<737:TIODIM>2.3.TX;2-M'})
    assert a != b, "Was expecting a to not equal b because the bicis do not match"
    assert a != @citation, "Was expecting a to not equal @citation because the bicis do not match"
    assert b == @citation, "Was expecting b to equal @citation because the bicis match"
    
    a = Cedilla::Citation.new({:genre => 'book', :document_id => '1234-1234'})
    b = Cedilla::Citation.new({:genre => 'journal', :document_id => '12345'})
    assert a != b, "Was expecting a to not equal b because the document_ids do not match"
    assert a != @citation, "Was expecting a to not equal @citation because the document_ids do not match"
    assert b == @citation, "Was expecting b to equal @citation because the document_ids match"
    
    a = Cedilla::Citation.new({:genre => 'book', :dissertation_number => '1234-1234'})
    b = Cedilla::Citation.new({:genre => 'journal', :dissertation_number => '1234567890ABC'})
    assert a != b, "Was expecting a to not equal b because the dissertation_numbers do not match"
    assert a != @citation, "Was expecting a to not equal @citation because the dissertation_numbers do not match"
    assert b == @citation, "Was expecting b to equal @citation because the dissertation_numbers match"
    
    a = Cedilla::Citation.new({:genre => 'book', :bibcode => '1234-1234'})
    b = Cedilla::Citation.new({:genre => 'journal', :bibcode => '2014MNRAS..84..308E'})
    assert a != b, "Was expecting a to not equal b because the bibcodes do not match"
    assert a != @citation, "Was expecting a to not equal @citation because the bibcodes do not match"
    assert b == @citation, "Was expecting b to equal @citation because the bibcodes match"
    
    a = Cedilla::Citation.new({:genre => 'book', :eric => '1234-1234'})
    b = Cedilla::Citation.new({:genre => 'journal', :eric => 'ED358673'})
    assert a != b, "Was expecting a to not equal b because the erics do not match"
    assert a != @citation, "Was expecting a to not equal @citation because the erics do not match"
    assert b == @citation, "Was expecting b to equal @citation because the erics match"
    
    a = Cedilla::Citation.new({:genre => 'book', :oai => '1234-1234'})
    b = Cedilla::Citation.new({:genre => 'journal', :oai => 'oai:foo.org:some-local-id-53'})
    assert a != b, "Was expecting a to not equal b because the oais do not match"
    assert a != @citation, "Was expecting a to not equal @citation because the oais do not match"
    assert b == @citation, "Was expecting b to equal @citation because the oais match"
    
    a = Cedilla::Citation.new({:genre => 'book', :nbn => '1234-1234'})
    b = Cedilla::Citation.new({:genre => 'journal', :nbn => 'nbn:ch:bel-9596'})
    assert a != b, "Was expecting a to not equal b because the nbns do not match"
    assert a != @citation, "Was expecting a to not equal @citation because the nbns do not match"
    assert b == @citation, "Was expecting b to equal @citation because the nbns match"
    
    a = Cedilla::Citation.new({:genre => 'book', :hdl => '1234-1234'})
    b = Cedilla::Citation.new({:genre => 'journal', :hdl => 'hdl:loc:pnp/cph.3c30104'})
    assert a != b, "Was expecting a to not equal b because the hdls do not match"
    assert a != @citation, "Was expecting a to not equal @citation because the hdls do not match"
    assert b == @citation, "Was expecting b to equal @citation because the hdls match"
    
    a = Cedilla::Citation.new({:genre => 'book', :title => '1234-1234'})
    b = Cedilla::Citation.new({:genre => 'journal', :title => 'Example Title'})
    assert a != b, "Was expecting a to not equal b because the titles do not match"
    assert a != @citation, "Was expecting a to not equal @citation because the titles do not match"
    assert b == @citation, "Was expecting b to equal @citation because the titles match"
    
    a = Cedilla::Citation.new({:genre => 'book', :article_title => '1234-1234'})
    b = Cedilla::Citation.new({:genre => 'journal', :article_title => 'Good Article'})
    assert a != b, "Was expecting a to not equal b because the article_titles do not match"
    assert a != @citation, "Was expecting a to not equal @citation because the article_titles do not match"
    assert b == @citation, "Was expecting b to equal @citation because the article_titles match"
    
    a = Cedilla::Citation.new({:genre => 'book', :book_title => '1234-1234'})
    b = Cedilla::Citation.new({:genre => 'journal', :book_title => 'Book title'})
    assert a != b, "Was expecting a to not equal b because the book_titles do not match"
    assert a != @citation, "Was expecting a to not equal @citation because the book_titles do not match"
    assert b == @citation, "Was expecting b to equal @citation because the book_titles match"
    
    a = Cedilla::Citation.new({:genre => 'book', :journal_title => '1234-1234'})
    b = Cedilla::Citation.new({:genre => 'journal', :journal_title => 'Some <escape me> \ Journal'})
    assert a != b, "Was expecting a to not equal b because the journal_titles do not match"
    assert a != @citation, "Was expecting a to not equal @citation because the journal_titles do not match"
    assert b == @citation, "Was expecting b to equal @citation because the journal_titles match"
    
    # Should not trigger equality!!
    a = Cedilla::Citation.new({:genre => 'book', :chapter_title => '1234-1234'})
    b = Cedilla::Citation.new({:genre => 'journal', :chapter_title => 'Chapter Seven'})
    assert a != b, "Was expecting a to not equal b because the chapter_titles are not a match point"
    assert a != @citation, "Was expecting a to not equal @citation because the chapter_titles are not a match point"
    assert b != @citation, "Was expecting b to equal @citation because the chapter_titles are not a match point"
    
    a = Cedilla::Citation.new({:genre => 'book', :short_title => '1234-1234'})
    b = Cedilla::Citation.new({:genre => 'journal', :short_title => ['Ex.', 'Example']})
    assert a != b, "Was expecting a to not equal b because the short_titles are not a match point"
    assert a != @citation, "Was expecting a to not equal @citation because the short_titles are not a match point"
    assert b != @citation, "Was expecting b to not equal @citation because the short_titles are not a match point"
  end

# --------------------------------------------------------------------------------------------------------    
  def test_valid
    # No genre or content type - should fail
    assert !Cedilla::Citation.new({}).valid?, "An empty citation should not pass the validation check!"
    
    # No genre - should fail
    assert !Cedilla::Citation.new({:issn => '12345'}).valid?, "A citation with no genre should not pass the validation check!"
    
    # No identifier and no title + author
    assert !Cedilla::Citation.new({:genre => 'journal'}).valid?, "A citation with a genre and no title or author or identifier should fail!"
    
    # No identifier and no title (has author though)
    assert !Cedilla::Citation.new({:genre => 'journal', :authors => [{:last_name => 'Doe'}]}).valid?, "A citation with a genre and and author but no title or identifier should fail!"
    
    # No identifier and no author (has title though)
    assert !Cedilla::Citation.new({:genre => 'journal', :title => 'Test'}).valid?, "A citation with a genre and title but no identifier and author should pass!"
    
    # has genre and author and title
    assert Cedilla::Citation.new({:genre => 'journal', :title => 'Test', :authors => [{:last_name => 'Doe'}]}).valid?, "A citation with a genre and title and author but no identifier should pass!"
    
    # has genre and identifier
    assert Cedilla::Citation.new({:genre => 'journal', :issn => '123'}).valid?, "A citation with a genre and identifier but no title or author should pass!"
    
    # has genre, identifier, author, and title
    assert Cedilla::Citation.new({:genre => 'journal', :isbn => '123', :title => 'Test', :authors => [{:last_name => 'Doe'}]}).valid?, "A citation with a genre and title and author but no identifier should pass!"
  end

  # --------------------------------------------------------------------------------------------------------  
  def test_has_identifier
    # Test that it returns false when it has no identifiers
    assert !Cedilla::Citation.new({}).has_identifier?, "Expected there to be no identifiers for an empty citation!"
    assert !Cedilla::Citation.new({:genre => 'journal'}).has_identifier?, "Expected there to be no identifiers with just genre defined!"
    assert !Cedilla::Citation.new({:genre => 'journal', :title => 'blah'}).has_identifier?, "Expected there to be no identifiers with just genre and title defined!"
    assert !Cedilla::Citation.new({:genre => 'article', :isbn => ''}).has_identifier?, "Expected there to not be an identifier for issn was empty!"
    assert !Cedilla::Citation.new({:genre => 'article', :issn => nil}).has_identifier?, "Expected there to not be an identifier for issn was nil!"
    
    assert Cedilla::Citation.new({:genre => 'article', :issn => '123'}).has_identifier?, "Expected there to be an identifier for issn!"
    assert Cedilla::Citation.new({:genre => 'article', :eissn => '123'}).has_identifier?, "Expected there to be an identifier for eissn!"
    assert Cedilla::Citation.new({:genre => 'article', :isbn => '123'}).has_identifier?, "Expected there to be an identifier for isbn!"
    assert Cedilla::Citation.new({:genre => 'article', :eisbn => '123'}).has_identifier?, "Expected there to be an identifier for eisbn!"
    assert Cedilla::Citation.new({:genre => 'article', :oclc => '123'}).has_identifier?, "Expected there to be an identifier for oclc!"
    assert Cedilla::Citation.new({:genre => 'article', :lccn => '123'}).has_identifier?, "Expected there to be an identifier for lccn!"
    assert Cedilla::Citation.new({:genre => 'article', :doi => '123'}).has_identifier?, "Expected there to be an identifier for doi!"
    assert Cedilla::Citation.new({:genre => 'article', :pmid => '123'}).has_identifier?, "Expected there to be an identifier for pmid!"
    assert Cedilla::Citation.new({:genre => 'article', :coden => '123'}).has_identifier?, "Expected there to be an identifier for coden!"
    assert Cedilla::Citation.new({:genre => 'article', :sici => '123'}).has_identifier?, "Expected there to be an identifier for sici!"
    assert Cedilla::Citation.new({:genre => 'article', :bici => '123'}).has_identifier?, "Expected there to be an identifier for bici!"
    assert Cedilla::Citation.new({:genre => 'article', :document_id => '123'}).has_identifier?, "Expected there to be an identifier for document_id!"
    assert Cedilla::Citation.new({:genre => 'article', :dissertation_number => '123'}).has_identifier?, "Expected there to be an identifier for :dissertation_number!"
    assert Cedilla::Citation.new({:genre => 'article', :bibcode => '123'}).has_identifier?, "Expected there to be an identifier for bibcode!"
    assert Cedilla::Citation.new({:genre => 'article', :eric => '123'}).has_identifier?, "Expected there to be an identifier for eric!"
    assert Cedilla::Citation.new({:genre => 'article', :oai => '123'}).has_identifier?, "Expected there to be an identifier for oai!"
    assert Cedilla::Citation.new({:genre => 'article', :nbn => '123'}).has_identifier?, "Expected there to be an identifier for nbn!"
    assert Cedilla::Citation.new({:genre => 'article', :hdl => '123'}).has_identifier?, "Expected there to be an identifier for hdl!"
    
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
    assert !Cedilla::Citation.new({:genre => 'journal'}).identifiers.collect{ |x,y| !y.nil? }.include?(true), "Expected there to be no identifiers with just genre and content type defined!"
    assert !Cedilla::Citation.new({:genre => 'journal', :title => 'blah'}).identifiers.collect{ |x,y| !y.nil? }.include?(true), "Expected there to be no identifiers with just genre and content type defined!"
    
    # Test the various identifiers to make sure they were each assigned in the setup step
    assert !@citation.identifiers['issn'].nil?, "Expected there to be an ISSN!"
    assert !@citation.identifiers['eissn'].nil?, "Expected there to be an EISSN!"
    assert !@citation.identifiers['isbn'].nil?, "Expected there to be an ISBN-10!"
    assert !@citation.identifiers['eisbn'].nil?, "Expected there to be an E-ISBN-10!"
    assert !@citation.identifiers['doi'].nil?, "Expected there to be a DOI!"
    assert !@citation.identifiers['oclc'].nil?, "Expected there to be an OCLC Id!"
    assert !@citation.identifiers['lccn'].nil?, "Expected there to be a LCCN!"
    assert !@citation.identifiers['pmid'].nil?, "Expected there to be a PubMed Id (PMID)!"
    assert !@citation.identifiers['coden'].nil?, "Expected there to be a CODEN!"
    assert !@citation.identifiers['sici'].nil?, "Expected there to be a SICI!"
    assert !@citation.identifiers['bici'].nil?, "Expected there to be a BICI!"
    assert !@citation.identifiers['dissertation_number'].nil?, "Expected there to be a Disertation_number!"
    assert !@citation.identifiers['document_id'].nil?, "Expected there to be a Document Id!"
    assert !@citation.identifiers['bibcode'].nil?, "Expected there to be a BIBCODE!"
    assert !@citation.identifiers['oai'].nil?, "Expected there to be a OAI!"
    assert !@citation.identifiers['nbn'].nil?, "Expected there to be a NBN!"
    assert !@citation.identifiers['hdl'].nil?, "Expected there to be a HDL!"
    assert !@citation.identifiers['eric'].nil?, "Expected there to be a ERIC!"
    
    assert_equal 18, @citation.identifiers.size, "Was expecting 18 identifiers to have been set!"
  end 
  
# --------------------------------------------------------------------------------------------------------  
  def test_to_hash
    hash = @citation.to_hash
    #hash: {"genre"=>"journal", "content_type"=>"electronic", "subject"=>"general", "cover_image"=>"http://campus.edu/logo.gif", 
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
    
    assert_equal 'article', hash['genre'], "Was expecting the genre to be 'article'!"
    assert_equal ['history', 'american history', 'HIST'], hash['subject'], "Was expecting the subject to be 'genral'!"
    assert_equal 'http://some.site.org/link/to/image/cover.jpg', hash['sample_cover_image'], "Was expecting the cover image to be 'http://some.site.org/link/to/image/cover.jpg'!"
    assert_equal 'This is a brief synopsis of the item ... blah blah blah', hash['abstract_text'], "Was expecting the abstract to be 'This is a brief synopsis of the item ... blah blah blah'!"
    
    assert_equal '0378-5955', hash['issn'], "Was expecting the issn to be '0378-5955'!"
    assert_equal '2434-561X', hash['eissn'], "Was expecting the eissn to be '2434-561X'!"
    assert_equal '817525766-0', hash['isbn'], "Was expecting the isbn-10 to be '817525766-0'!"
    assert_equal '0-440-18293-X', hash['eisbn'], "Was expecting the eisbn-10 to be '0-440-18293-X'!"
    assert_equal 'ocm123456789', hash['oclc'], "Was expecting the oclc to be 'ocm123456789'!"
    assert_equal '2004-00123', hash['lccn'], "Was expecting the lccn to be '2004-00123'!"
    assert_equal '10.1000/182', hash['doi'], "Was expecting the doi to be '10.1000/182'!"
    assert_equal '6996886', hash['pmid'], "Was expecting the pmid to be '6996886'!"
    assert_equal 'NATUAS', hash['coden'], "Was expecting the coden to be 'NATUAS'!"
    assert_equal '0378-5955(199412)45:10<737:TIODIM>2.3.TX;2-M', hash['sici'], "Was expecting the sici to be '0378-5955(199412)45:10<737:TIODIM>2.3.TX;2-M'!"
    assert_equal '817525766-0(199412)45:10<737:TIODIM>2.3.TX;2-M', hash['bici'], "Was expecting the bici to be '817525766-0(199412)45:10<737:TIODIM>2.3.TX;2-M'!"
    assert_equal '1234567890ABC', hash['dissertation_number'], "Was expecting the dissertation number to be '1234567890ABC'!"
    assert_equal '12345', hash['document_id'], "Was expecting the document id to be '12345'!"
    assert_equal '2014MNRAS..84..308E', hash['bibcode'], "Was expecting the bibcode to be '2014MNRAS..84..308E'!"
    assert_equal 'ED358673', hash['eric'], "Was expecting the eric to be 'ED358673'!"
    assert_equal 'oai:foo.org:some-local-id-53', hash['oai'], "Was expecting the oai to be 'oai:foo.org:some-local-id-53'!"
    assert_equal 'nbn:ch:bel-9596', hash['nbn'], "Was expecting the nbn to be 'nbn:ch:bel-9596'!"
    assert_equal 'hdl:loc:pnp/cph.3c30104', hash['hdl'], "Was expecting the hdl to be 'hdl:loc:pnp/cph.3c30104'!"
    
    assert_equal 'Example Title', hash['title'], "Was expecting the title to be 'Example Title'!"
    assert_equal 'Good Article', hash['article_title'], "Was expecting the article title to be 'Good Article'!"
    assert_equal 'Some <escape me> \ Journal', hash['journal_title'], "Was expecting the journal title to be 'Some <escape me> \ Journal'!"
    assert_equal 'Book title', hash['book_title'], "Was expecting the book title to be 'Book title'!"
    assert_equal 'Chapter Seven', hash['chapter_title'], "Was expecting the chapter title to be 'Chapter Seven'!"
    assert_equal ['Ex.', 'Example'], hash['short_title'], "Was expecting the short titles to be an array ['Ex.', 'Example']!"
    
    assert_equal 'Bargain Books', hash['publisher'], "Was expecting the publisher to be 'Bargain Books'!"
    assert_equal '2010', hash['publication_date'], "Was expecting the publication date to be '2010'!"
    assert_equal 'New York', hash['publication_place'], "Was expecting the publication place to be 'New York'!"
    
    assert_equal '2010', hash['year'], "Was expecting the year to be '2010'!"
    assert_equal '03', hash['month'], "Was expecting the month to be '03'!"
    assert_equal '15', hash['day'], "Was expecting the day to be '12'!"
    assert_equal '23', hash['volume'], "Was expecting the volume to be '23'!"
    assert_equal '1', hash['issue'], "Was expecting the issue to be '1'!"
    assert_equal 'My institute', hash['institution'], "Was expecting the institute to be 'My institute'!"
    assert_equal '13-56', hash['series'], "Was expecting the series to be '13-56'!"
    assert_equal '34', hash['article_number'], "Was expecting the article number to be '34'!"
    assert_equal 'v. 23 - 1', hash['enumeration'], "Was expecting the enumeration to be 'v. 23 - 1'!"
    assert_equal 'Spring', hash['season'], "Was expecting the season to be 'Spring'!"
    assert_equal '1st', hash['quarter'], "Was expecting the quarter to be '1st'!"
    assert_equal '?', hash['part'], "Was expecting the part to be '?'!"
    assert_equal '2nd', hash['edition'], "Was expecting the edition to be '2nd'!"
    assert_equal 'English', hash['language'], "Was expecting the language to be 'English'!"
    
    assert_equal '34', hash['start_page'], "Was expecting the start page to be '34'!"
    assert_equal '45', hash['end_page'], "Was expecting the end page to be '45'!"
    assert_equal '34-45', hash['pages'], "Was expecting the pages to be '34-45'!"
    
    assert_equal ['what?'], hash['extras']['what'], "Was expecting the extras array to have been included in the hash!"
    
    first_author = hash['authors'].first
    assert_equal 'Doe', first_author['last_name'], "Was expecting the others array to have been included in the hash!"
  end
  
  # --------------------------------------------------------------------------------------------------------  
  def test_allocation_of_extras
    assert_equal 5, @citation.extras.count, "Was expecting to find five extras!"
    assert_equal 'when', @citation.extras['when'][0], "Was expecting extras to contain 'when' => ['when']!"
  
    @citation.extras['when'] << 'when2'
    @citation.extras['blah'] = ['blah']
  
    assert_equal 6, @citation.extras.count, "Was expecting to find six extras!"
    assert_equal 2, @citation.extras['when'].count, "Was expecting to find two values in when!"
    assert_equal 'when', @citation.extras['when'][0], "Was expecting extras to contain 'when' => ['when']!"
    assert_equal 'when2', @citation.extras['when'][1], "Was expecting extras to contain 'when' => ['when2']!"
    assert_equal 'blah', @citation.extras['blah'][0], "Was expecting extras to contain 'blah' => ['blah']!"
  
    assert_equal ['when', 'when2'], @citation.extras['when'], "Was expecting extras to contain 'when' => ['when', 'when2']!"
    assert_equal ['blah'], @citation.extras['blah'], "Was expecting extras to contain 'blah' => ['blah']!"
  
    @citation.extras.delete('blah')
    assert_equal 5, @citation.extras.count, "Was expecting to find five extras!"
  
    @citation.extras.clear
    assert_equal 0, @citation.extras.count, "Was expecting to find NO extras!"
  end
end