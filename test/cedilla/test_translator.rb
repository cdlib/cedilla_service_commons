require_relative '../test_helper'

class TestTranslator < Minitest::Test

# -------------------------------------------------------------------------------------------------------  
  def test_from_cedilla_json_for_book
    # Check invalid jsons
    INVALID_JSONS.each do |json|
      request = Cedilla::Translator.from_cedilla_json(json)
      
      assert request.nil?, "Was expecting that the invalid JSON, #{json}, would not produce a valid Cedilla::Request object!"
    end

    [BOOK_JSON, JOURNAL_JSON, ARTICLE_JSON, CHAPTER_JSON].each do |source|
      request = Cedilla::Translator.from_cedilla_json(source)
      hash = JSON.parse(source)
      
      hash.each do |key, val|
        if key == 'citation'
          assert_equal Cedilla::Citation.new(val), request.send("#{key}"), "Was expecting #{key} to be #{val}" 
        else
          assert_equal val, request.send("#{key}"), "Was expecting #{key} to be #{val}" 
        end
      end

    end
  end
  
# -------------------------------------------------------------------------------------------------------  
  def test_to_cedilla_json
    service_name = 'service_test'
    
    citation = Cedilla::Citation.new({:genre => 'journal', :issn => '12345'})
    json = Cedilla::Translator.to_cedilla_json('ABC', citation)

    assert json.include?('"genre":"journal"'), "Was expecting a query string with generic attribute names from the translator!"
    assert json.include?('"issn":"12345"'), "Was expecting a query string with generic attribute names from the translator!"
    
    citation = Cedilla::Citation.new({:genre => 'journal', :title => 'A Tale Of Two Cities', :authors => [{:last_name => 'Dickens'}]})
    assert !citation.authors.empty?, "Was expecting some authors!"
    assert_equal 'Dickens', citation.authors.first.last_name, "Was expecting author's last name to be 'Dickens'!"
    
    json = Cedilla::Translator.to_cedilla_json('XYZ', citation)
    assert json.include?('"title":"A Tale Of Two Cities"'), "Was expecting a query string with generic attribute names from the translator!"
    assert json.include?('"authors":[{"full_name":"Dickens","last_name":"Dickens"'), "Was expecting a query string with generic attribute names from the translator!"

  end

# -------------------------------------------------------------------------------------------------------  
  def test_hash_to_query_string
    citation = Cedilla::Citation.new({:genre => 'journal', :issn => '12345'})
    hash = citation.to_hash
    query_string = Cedilla::Translator.hash_to_query_string(hash)
    
    assert query_string.include?('genre=journal'), "Was expecting a query string with genre attribute to be 'journal'!"
    assert query_string.include?('issn=12345'), "Was expecting a query string with content_type attribute to be 'electronic'!"
    
    citation = Cedilla::Citation.new({:genre => 'journal', :title => 'A Tale Of Two Cities', :authors => [{:last_name => 'Dickens'}]})
    query_string = Cedilla::Translator.hash_to_query_string(citation.to_hash)
    #query_string: genre=journal&content_type=full_text&title=A%20Tale%20Of%20Two%20Cities&full_name=Dickens&last_name=Dickens
    
    assert query_string.include?('genre=journal'), "Was expecting a query string with genre attribute to be 'journal'!"
    assert query_string.include?('title=A%20Tale%20Of%20Two%20Cities'), "Was expecting a query string with title attribute to be 'A%20Tale%20Of%20Two%20Cities'!"
    
    citation = Cedilla::Citation.new({:genre => 'book', :title => 'The Metamorphosis', :date => '2014', 
                                      :authors => [{:last_name => 'Dickens', :first_initial => 'B.'}, {:last_name => 'Kafka', :first_name => 'Franz'}],
                                      :resources => [{:source => 'source 1', :location => 'location 1'}, {:source => 'source 2', :target => 'http://www.ucop.edu/link/to/item', :availability => true}]})
    hash = citation.to_hash
    #hash: {"genre"=>"book", "content_type"=>"electronic", "title"=>"The Metamorphosis", "date"=>"2014", 
    #       "authors"=>[{"full_name"=>"B. Dickens", "last_name"=>"Dickens", "first_initial"=>"B.", "initials"=>"B."}, {"full_name"=>"Franz Kafka", "last_name"=>"Kafka", "first_name"=>"Franz", "first_initial"=>"F.", "initials"=>"F."}], 
    #       "resources"=>[{"source"=>"source 1", "location"=>"location 1", "availability"=>false},{"source"=>"source 2", "target"=>"http://www.ucop.edu/link/to/item", "availability"=>true}]}
    
    query_string = Cedilla::Translator.hash_to_query_string(hash)

    #query_string: genre=book&content_type=electronic&title=The%20Metamorphosis&date=2014
    #              &full_name=B.%20Dickens&last_name=Dickens&first_initial=B.&initials=B.&full_name=Franz%20Kafka&last_name=Kafka&first_name=Franz&first_initial=F.&initials=F.
    #              &source=source%201&location=location%201&availability=false&source=source%202&target=http://www.ucop.edu/link/to/item&availability=true
    assert query_string.include?('title=The%20Metamorphosis'), "Was expecting a query string with title attribute to be 'The%20Metamorphosis'!"
    assert query_string.include?('full_name=Franz%20Kafka'), "Was expecting a query string with full_name attribute to be 'Franz%20Kafka'!"
    assert query_string.include?('first_initial=F.'), "Was expecting a query string with first_initial attribute to be 'F.'!"
    assert query_string.include?('target=http://www.ucop.edu/link/to/ite'), "Was expecting a query string with target attribute to be 'http://www.ucop.edu/link/to/ite'!"
  end

end